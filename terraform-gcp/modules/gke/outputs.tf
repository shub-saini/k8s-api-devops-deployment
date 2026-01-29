variable "name" {
  description = "Name of the GKE cluster"
  type        = string
}

variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region for regional cluster, or zone for zonal cluster"
  type        = string
}

variable "cluster_type" {
  description = "Type of cluster: REGIONAL or ZONAL"
  type        = string
  default     = "ZONAL"
  validation {
    condition     = contains(["REGIONAL", "ZONAL"], var.cluster_type)
    error_message = "cluster_type must be either REGIONAL or ZONAL"
  }
}

# NETWORK CONFIGURATION
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
  description = "Enable private cluster configuration"
  type        = bool
  default     = true
}

variable "enable_private_endpoint" {
  description = "Whether the master's internal IP is used as the cluster endpoint"
  type        = bool
  default     = false
}

variable "master_ipv4_cidr_block" {
  description = "The IP range in CIDR notation for the hosted master network"
  type        = string
  default     = "172.16.0.0/28"
}

variable "master_authorized_networks" {
  description = "List of master authorized networks"
  type = list(object({
    cidr_block   = string
    display_name = string
  }))
  default = []
}

# CLUSTER CONFIGURATION
variable "kubernetes_version" {
  description = "Kubernetes version for the cluster. Use 'latest' for latest stable version"
  type        = string
  default     = "latest"
}

variable "release_channel" {
  description = "Release channel for GKE cluster (RAPID, REGULAR, STABLE, UNSPECIFIED)"
  type        = string
  default     = "REGULAR"
}

variable "maintenance_window" {
  description = "Maintenance window configuration"
  type = object({
    start_time = string # Format: "2023-01-01T00:00:00Z"
    end_time   = string
    recurrence = string # Format: "FREQ=WEEKLY;BYDAY=SA,SU"
  })
  default = null
}

variable "enable_autopilot" {
  description = "Enable Autopilot mode (if true, node_pools are ignored)"
  type        = bool
  default     = false
}

# NODE POOL CONFIGURATION (Dynamic!)
variable "node_pools" {
  description = "List of node pools to create"
  type = list(object({
    name               = string
    machine_type       = optional(string, "e2-medium")
    disk_size_gb       = optional(number, 100)
    disk_type          = optional(string, "pd-standard")
    image_type         = optional(string, "COS_CONTAINERD")
    
    # Auto-scaling
    min_node_count     = optional(number, 1)
    max_node_count     = optional(number, 3)
    initial_node_count = optional(number, 1)
    
    # Node configuration
    preemptible        = optional(bool, false)
    spot               = optional(bool, false)
    
    # Taints for pod scheduling
    taints = optional(list(object({
      key    = string
      value  = string
      effect = string # NO_SCHEDULE, PREFER_NO_SCHEDULE, NO_EXECUTE
    })), [])
    
    # Labels
    labels = optional(map(string), {})
    
    # Node tags (for firewall rules)
    tags = optional(list(string), [])
    
    # Service account
    service_account = optional(string)  # If null, creates a new one per pool
    oauth_scopes    = optional(list(string), [
      "https://www.googleapis.com/auth/cloud-platform"
    ])
    
    # Node locations (specific zones for this pool)
    node_locations = optional(list(string))
    
    # Upgrade settings
    max_surge       = optional(number, 1)
    max_unavailable = optional(number, 0)
    
    # GKE metadata
    enable_secure_boot          = optional(bool, true)
    enable_integrity_monitoring = optional(bool, true)
  }))
  
  default = [
    {
      name               = "default-pool"
      machine_type       = "e2-medium"
      min_node_count     = 1
      max_node_count     = 3
      initial_node_count = 1
    }
  ]
}

# WORKLOAD IDENTITY
variable "enable_workload_identity" {
  description = "Enable Workload Identity"
  type        = bool
  default     = true
}

variable "workload_identity_namespace" {
  description = "Workload Identity namespace (defaults to project_id.svc.id.goog)"
  type        = string
  default     = null
}

# ADDONS
variable "enable_horizontal_pod_autoscaling" {
  description = "Enable Horizontal Pod Autoscaling addon"
  type        = bool
  default     = true
}

variable "enable_http_load_balancing" {
  description = "Enable HTTP Load Balancing addon"
  type        = bool
  default     = true
}

variable "enable_network_policy" {
  description = "Enable Network Policy addon"
  type        = bool
  default     = true
}

variable "enable_gce_persistent_disk_csi_driver" {
  description = "Enable GCE Persistent Disk CSI Driver"
  type        = bool
  default     = true
}

variable "enable_gcp_filestore_csi_driver" {
  description = "Enable GCP Filestore CSI Driver"
  type        = bool
  default     = false
}

variable "enable_gke_backup_agent" {
  description = "Enable GKE Backup Agent"
  type        = bool
  default     = false
}

# LOGGING & MONITORING
variable "logging_service" {
  description = "Logging service to use (logging.googleapis.com/kubernetes or none)"
  type        = string
  default     = "logging.googleapis.com/kubernetes"
}

variable "monitoring_service" {
  description = "Monitoring service to use (monitoring.googleapis.com/kubernetes or none)"
  type        = string
  default     = "monitoring.googleapis.com/kubernetes"
}

variable "enable_managed_prometheus" {
  description = "Enable managed Prometheus for cluster monitoring"
  type        = bool
  default     = false
}

# SECURITY
variable "enable_binary_authorization" {
  description = "Enable Binary Authorization"
  type        = bool
  default     = false
}

variable "enable_shielded_nodes" {
  description = "Enable Shielded GKE Nodes"
  type        = bool
  default     = true
}

variable "database_encryption_key_name" {
  description = "KMS key for database encryption (CMEK)"
  type        = string
  default     = null
}

# RESOURCE LABELS
variable "resource_labels" {
  description = "Labels to apply to all resources"
  type        = map(string)
  default     = {}
}

# DELETION PROTECTION
variable "deletion_protection" {
  description = "Enable deletion protection on the cluster"
  type        = bool
  default     = true
}