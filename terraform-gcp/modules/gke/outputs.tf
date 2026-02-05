output "cluster_name" {
  description = "The name of the cluster"
  value       = google_container_cluster.primary.name
}

# output "cluster_endpoint" {
#   description = "The IP of the cluster master"
#   value       = google_container_cluster.primary.endpoint
#   sensitive   = true
# }

# output "cluster_ca_certificate" {
#   description = "The cluster CA certificate (base64 encoded)"
#   value       = google_container_cluster.primary.master_auth[0].cluster_ca_certificate
#   sensitive   = true
# }

output "cluster_location" {
  description = "The location (region) of the cluster"
  value       = google_container_cluster.primary.location
}

output "node_pools" {
  description = "Node pool details"
  value = {
    for name, pool in google_container_node_pool.pools : name => {
      name = pool.name
      size = "${pool.autoscaling[0].min_node_count}-${pool.autoscaling[0].max_node_count} nodes"
    }
  }
}

output "node_pool_service_accounts" {
  description = "Service account emails for each node pool"
  value = {
    for name, sa in google_service_account.node_pool_sa : name => sa.email
  }
}

output "kubectl_command" {
  description = "Command to configure kubectl"
  value       = "gcloud container clusters get-credentials ${google_container_cluster.primary.name} --zone=${var.zone} --project=${var.project_id}"
}

output "workload_identity_pool_id" {
  value = "${var.project_id}.svc.id.goog"
}

output "cluster_endpoint" {
  value = google_container_cluster.primary.endpoint
}

output "cluster_ca_certificate" {
  value = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
}