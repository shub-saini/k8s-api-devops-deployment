resource "google_service_account" "node_pool_sa" {
  for_each = {
    for pool in var.node_pools : pool.name => pool
    if !var.enable_autopilot && pool.service_account == null
  }

  account_id   = "${var.name}-${each.value.name}-sa"
  display_name = "Service Account for ${var.name} ${each.value.name}"
  project      = var.project_id
}
