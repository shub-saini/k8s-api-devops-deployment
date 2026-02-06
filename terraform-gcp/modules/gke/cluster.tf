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


  # Workload Identity (lets K8s pods authenticate as GCP service accounts)
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  secret_manager_config {
    enabled = true
  }

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


  enable_shielded_nodes = true
  resource_labels       = var.resource_labels
  deletion_protection   = var.deletion_protection

  lifecycle {
    ignore_changes = [
      initial_node_count,
      node_config,
    ]
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
}
