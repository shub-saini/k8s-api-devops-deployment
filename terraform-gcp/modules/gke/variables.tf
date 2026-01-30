variable "name" {
  description = "Name of the GKE cluster"
  type        = string
}

variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region for the cluster"
  type        = string
}

variable "network_self_link" {
  description = "Self link of the VPC network"
  type        = string
}

variable "subnetwork_self_link" {
  description = "Self link of the subnet for GKE nodes"
  type        = string
}

variable "pods_secondary_range_name" {
  description = "Name of the secondary range for pods"
  type        = string
}

variable "services_secondary_range_name" {
  description = "Name of the secondary range for services"
  type        = string
}

# PRIVATE CLUSTER CONFIG
variable "enable_private_cluster" {
  description = "Enable private cluster (nodes have no external IPs)"
  type        = bool
  default     = true
}

variable "enable_private_endpoint" {
  description = "Make master API only accessible via internal IP"
  type        = bool
  default     = false
}

variable "master_ipv4_cidr_block" {
  description = "IP range for the master (use a /28)"
  type        = string
}

# variable "master_authorized_networks" {
#   description = "CIDRs that can access the master API"
#   type = list(object({
#     cidr_block   = string
#     display_name = string
#   }))
#   default = []
# }

# CLUSTER SETTINGS
variable "release_channel" {
  description = "GKE release channel: RAPID, REGULAR, or STABLE"
  type        = string
  default     = "REGULAR"
}

variable "deletion_protection" {
  description = "Prevent accidental cluster deletion"
  type        = bool
  default     = false
}

variable "node_pools" {
  description = "List of node pools"
  type = list(object({
    name         = string
    machine_type = optional(string, "e2-medium")
    disk_size_gb = optional(number, 100)
    disk_type    = optional(string, "pd-standard") # or "pd-ssd"

    # Scaling
    min_node_count     = optional(number, 1)
    max_node_count     = optional(number, 3)
    initial_node_count = optional(number, 1)

    # Cost optimization
    spot = optional(bool, false) # Cheap but can be preempted

    # Pod scheduling
    taints = optional(list(object({
      key    = string
      value  = string
      effect = string # NO_SCHEDULE, PREFER_NO_SCHEDULE, NO_EXECUTE
    })), [])

    labels = optional(map(string), {})

    # Firewall tags
    tags = optional(list(string), [])

    # Service account (null = auto-create per pool)
    service_account = optional(string)

    # Specific zones for this pool (optional)
    node_locations = optional(list(string))
  }))

  #   default = [
  #     {
  #       name               = "default-pool"
  #       machine_type       = "e2-medium"
  #       min_node_count     = 1
  #       max_node_count     = 3
  #       initial_node_count = 1
  #     }
  #   ]
}

# FEATURES
variable "enable_workload_identity" {
  description = "Enable Workload Identity (needed for K8s pods to use GCP services)"
  type        = bool
  default     = true
}

variable "enable_network_policy" {
  description = "Enable Network Policy (for pod-to-pod network rules)"
  type        = bool
  default     = false
}

variable "resource_labels" {
  description = "Labels to apply to the cluster"
  type        = map(string)
  default     = {}
}