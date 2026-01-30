output "vpc_id" {
  description = "The ID of the VPC"
  value       = google_compute_network.vpc.id
}

output "vpc_name" {
  description = "The name of the VPC"
  value       = google_compute_network.vpc.name
}

output "vpc_self_link" {
  description = "The self link of the VPC"
  value       = google_compute_network.vpc.self_link
}

output "subnets" {
  description = "Map of all subnets created"
  value = {
    for name, subnet in google_compute_subnetwork.subnets : name => {
      id                  = subnet.id
      name                = subnet.name
      self_link           = subnet.self_link
      cidr_range          = subnet.ip_cidr_range
      region              = subnet.region
      secondary_ip_ranges = subnet.secondary_ip_range
    }
  }
}

# DYNAMIC NAT OUTPUTS
output "nat_ips" {
  description = "List of NAT IP addresses"
  value       = local.create_nat && var.cloud_nat.nat_ip_allocate_option == "MANUAL_ONLY" ? google_compute_address.nat[*].address : []
}

output "router_name" {
  description = "The name of the Cloud Router"
  value       = local.create_nat ? google_compute_router.router[0].name : null
}

output "router_self_link" {
  description = "The self link of the Cloud Router"
  value       = local.create_nat ? google_compute_router.router[0].self_link : null
}

# DYNAMIC FIREWALL OUTPUTS
output "firewall_rules" {
  description = "Map of all firewall rules created"
  value = {
    for name, rule in google_compute_firewall.rules : name => {
      id        = rule.id
      name      = rule.name
      self_link = rule.self_link
    }
  }
}