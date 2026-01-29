variable "name" {
  description = "Name prefix of all resouces in this VPC"
  type        = string
}

variable "region" {
  type = string
}

variable "project_id" {
  type = string
}

variable "routing_mode" {
  description = "VPC routing mode (REGIONAL or GLOBAL)"
  type        = string
  default     = "REGIONAL"
}

variable "subnets" {
  description = "List of subnets to create"
  type = list(object({
    name                     = string
    ip_cidr_range            = string
    region                   = optional(string) # Uses var.region and REGIONAL routing if not specified
    private_ip_google_access = optional(bool, true)
    stack_type               = optional(string, "IPV4_ONLY")

    secondary_ip_ranges = optional(list(object({
      range_name    = string
      ip_cidr_range = string
    })), [])
  }))
}

# variable "routes" {
#   description = "List of routes to create"
#   type = list(object({
#     name                = string
#     description         = optional(string)
#     dest_range          = string
#     priority            = optional(number, 1000)
#     tags                = optional(list(string))
#     next_hop_gateway    = optional(string)
#     next_hop_ip         = optional(string)
#     next_hop_instance   = optional(string)
#     next_hop_vpn_tunnel = optional(string)
#   }))

#   default = [
#     {
#       name             = "default-route"
#       dest_range       = "0.0.0.0/0"
#       next_hop_gateway = "default-internet-gateway"
#     }
#   ]
# }

variable "cloud_nat" {
  description = "Cloud NAT configuration. Set to null to disable NAT entirely"
  type = object({
    name                               = optional(string, "nat")
    nat_ip_allocate_option             = optional(string, "MANUAL_ONLY")
    source_subnetwork_ip_ranges_to_nat = optional(string, "LIST_OF_SUBNETWORKS") # or ALL_SUBNETWORKS_ALL_IP_RANGES

    nat_subnets = list(object({
      subnet_name             = string
      source_ip_ranges_to_nat = optional(list(string), ["ALL_IP_RANGES"])
    }))

    # Manual IPs (only used if nat_ip_allocate_option = MANUAL_ONLY)
    manual_ip_count = optional(number, 1)
  })
}

variable "firewall_rules" {
  description = "List of firewall rules to create"
  type = list(object({
    name                    = string
    description             = optional(string)
    priority                = optional(number, 1000)
    direction               = optional(string, "INGRESS")
    disabled                = optional(bool, false)
    source_ranges           = optional(list(string))
    destination_ranges      = optional(list(string))
    source_tags             = optional(list(string))
    source_service_accounts = optional(list(string))
    target_tags             = optional(list(string))
    target_service_accounts = optional(list(string))

    allow = optional(list(object({
      protocol = string
      ports    = optional(list(string))
    })), [])

    deny = optional(list(object({
      protocol = string
      ports    = optional(list(string))
    })), [])

    log_config = optional(object({
      metadata = string # INCLUDE_ALL_METADATA or EXCLUDE_ALL_METADATA
    }))

  }))
}