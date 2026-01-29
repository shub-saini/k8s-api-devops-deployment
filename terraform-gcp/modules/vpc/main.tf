resource "google_compute_network" "vpc" {
  name                            = var.name
  routing_mode                    = var.routing_mode
  auto_create_subnetworks         = false
  delete_default_routes_on_create = true
  project                         = var.project_id
}

resource "google_compute_subnetwork" "subnets" {
  for_each = { for subnet in var.subnets : subnet.name => subnet }

  name                     = "${var.name}-${each.value.name}"
  ip_cidr_range            = each.value.ip_cidr_range
  region                   = each.value.region != null ? each.value.region : var.region
  network                  = google_compute_network.vpc.id
  private_ip_google_access = each.value.private_ip_google_access
  stack_type               = each.value.stack_type
  project                  = var.project_id

  dynamic "secondary_ip_range" {
    for_each = each.value.secondary_ip_ranges
    content {
      range_name    = secondary_ip_range.value.range_name
      ip_cidr_range = secondary_ip_range.value.ip_cidr_range
    }

  }
}

# DYNAMIC ROUTES - Add as many custom routes as you need!
# resource "google_compute_route" "routes" {
#   for_each = { for route in var.routes : route.name => route }

#   name             = "${var.name}-${each.value.name}"
#   description      = each.value.description
#   dest_range       = each.value.dest_range
#   network          = google_compute_network.vpc.id
#   priority         = each.value.priority
#   tags             = each.value.tags
#   project          = var.project_id
  
#   next_hop_gateway     = each.value.next_hop_gateway
#   next_hop_ip          = each.value.next_hop_ip
#   next_hop_instance    = each.value.next_hop_instance
#   next_hop_vpn_tunnel  = each.value.next_hop_vpn_tunnel
# }

# NAT External IPs (only if using MANUAL_ONLY allocation)
resource "google_compute_address" "nat" {
  count = local.create_nat && var.cloud_nat.nat_ip_allocate_option == "MANUAL_ONLY" ? var.cloud_nat.manual_ip_count : 0

  name         = "${var.name}-${var.cloud_nat.name}-ip-${count.index + 1}"
  address_type = "EXTERNAL"
  network_tier = "PREMIUM"
  region       = var.region
  project      = var.project_id
}

# Cloud Router
resource "google_compute_router" "router" {
  count = local.create_nat ? 1 : 0

  name    = "${var.name}-router"
  region  = var.region
  network = google_compute_network.vpc.id
  project = var.project_id
}

resource "google_compute_router_nat" "nat" {
  count = local.create_nat ? 1 : 0

  name    = "${var.name}-${var.cloud_nat.name}"
  region  = var.region
  router  = google_compute_router.router[0].name
  project = var.project_id

  nat_ip_allocate_option             = var.cloud_nat.nat_ip_allocate_option
  source_subnetwork_ip_ranges_to_nat = var.cloud_nat.source_subnetwork_ip_ranges_to_nat

  # Only set nat_ips if using MANUAL allocation
  nat_ips = var.cloud_nat.nat_ip_allocate_option == "MANUAL_ONLY" ? google_compute_address.nat[*].self_link : null

  dynamic "subnetwork" {
    for_each = var.cloud_nat.nat_subnets
    content {
      name                    = local.subnet_map[subnetwork.value.subnet_name].self_link
      source_ip_ranges_to_nat = subnetwork.value.source_ip_ranges_to_nat
    }
  }
}

resource "google_compute_firewall" "rules" {
  for_each = { for rule in var.firewall_rules : rule.name => rule }

  name        = "${var.name}-${each.value.name}"
  network     = google_compute_network.vpc.name
  project     = var.project_id
  description = each.value.description
  priority    = each.value.priority
  direction   = each.value.direction
  disabled    = each.value.disabled

  source_ranges           = each.value.source_ranges
  destination_ranges      = each.value.destination_ranges
  source_tags             = each.value.source_tags
  source_service_accounts = each.value.source_service_accounts
  target_tags             = each.value.target_tags
  target_service_accounts = each.value.target_service_accounts

  dynamic "allow" {
    for_each = each.value.allow
    content {
      protocol = allow.value.protocol
      ports    = allow.value.ports
    }
  }

  dynamic "deny" {
    for_each = each.value.deny
    content {
      protocol = deny.value.protocol
      ports    = deny.value.ports
    }
  }

  dynamic "log_config" {
    for_each = each.value.log_config != null ? [each.value.log_config] : []
    content {
      metadata = log_config.value.metadata
    }
  }
}