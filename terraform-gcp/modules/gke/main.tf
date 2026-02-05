resource "google_service_account" "node_pool_sa" {
  for_each = {
    for pool in var.node_pools : pool.name => pool
    if pool.service_account == null
  }

  account_id   = "${var.name}-${each.value.name}-sa"
  display_name = "Service Account for ${var.name} ${each.value.name}"
  project      = var.project_id
}

resource "google_project_iam_member" "node_pool_logging" {
  for_each = google_service_account.node_pool_sa

  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${each.value.email}"
}

resource "google_project_iam_member" "node_pool_monitoring" {
  for_each = google_service_account.node_pool_sa

  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${each.value.email}"
}

resource "google_project_iam_member" "node_pool_metadata" {
  for_each = google_service_account.node_pool_sa

  project = var.project_id
  role    = "roles/stackdriver.resourceMetadata.writer"
  member  = "serviceAccount:${each.value.email}"
}

resource "google_container_cluster" "primary" {
  name     = var.name
  project  = var.project_id
  location = var.zone

  network    = var.network_self_link
  subnetwork = var.subnetwork_self_link

  # Remove default node pool (we'll create custom ones)
  remove_default_node_pool = true
  initial_node_count       = 1

  release_channel {
    channel = var.release_channel
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = var.pods_secondary_range_name
    services_secondary_range_name = var.services_secondary_range_name
  }

  dynamic "private_cluster_config" {
    for_each = var.enable_private_cluster ? [1] : []
    content {
      enable_private_nodes    = true
      enable_private_endpoint = var.enable_private_endpoint
      master_ipv4_cidr_block  = var.master_ipv4_cidr_block
    }
  }

  # Master authorized networks (who can access K8s API)
  #   dynamic "master_authorized_networks_config" {
  #     for_each = length(var.master_authorized_networks) > 0 ? [1] : []
  #     content {
  #       dynamic "cidr_blocks" {
  #         for_each = var.master_authorized_networks
  #         content {
  #           cidr_block   = cidr_blocks.value.cidr_block
  #           display_name = cidr_blocks.value.display_name
  #         }
  #       }
  #     }
  #   }

  # Workload Identity (lets K8s pods authenticate as GCP service accounts)
  dynamic "workload_identity_config" {
    for_each = var.enable_workload_identity ? [1] : []
    content {
      workload_pool = "${var.project_id}.svc.id.goog"
    }
  }

  # Network policy
  dynamic "network_policy" {
    for_each = var.enable_network_policy ? [1] : []
    content {
      enabled  = true
      provider = "PROVIDER_UNSPECIFIED" # Uses Calico
    }
  }

  # Logging & monitoring (Cloud Operations)
  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"

  # Security
  enable_shielded_nodes = true

  # Labels
  resource_labels = var.resource_labels

  deletion_protection = var.deletion_protection

  lifecycle {
    ignore_changes = [
      initial_node_count,
      node_config,
    ]
  }
}

resource "google_container_node_pool" "pools" {
  for_each = { for pool in var.node_pools : pool.name => pool }

  name     = each.value.name
  project  = var.project_id
  location = var.zone
  cluster  = google_container_cluster.primary.name

  # Specific zones for this pool
  node_locations     = each.value.node_locations
  initial_node_count = each.value.initial_node_count

  autoscaling {
    min_node_count = each.value.min_node_count
    max_node_count = each.value.max_node_count
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    machine_type = each.value.machine_type
    disk_size_gb = each.value.disk_size_gb
    disk_type    = each.value.disk_type

    spot = each.value.spot

    # Service account (use provided one or auto-created one)
    service_account = each.value.service_account != null ? each.value.service_account : google_service_account.node_pool_sa[each.key].email

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    labels = merge(
      each.value.labels,
      {
        "cluster"   = var.name
        "node-pool" = each.value.name
      }
    )

    tags = concat(
      each.value.tags,
      ["gke-${var.name}", "gke-${var.name}-${each.value.name}"]
    )

    dynamic "taint" {
      for_each = each.value.taints
      content {
        key    = taint.value.key
        value  = taint.value.value
        effect = taint.value.effect
      }
    }

    # Workload Identity
    dynamic "workload_metadata_config" {
      for_each = var.enable_workload_identity ? [1] : []
      content {
        mode = "GKE_METADATA"
      }
    }

    # Shielded nodes (security)
    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }

    metadata = {
      disable-legacy-endpoints = "true"
    }
  }

  lifecycle {
    ignore_changes = [
      initial_node_count,
    ]
  }
}