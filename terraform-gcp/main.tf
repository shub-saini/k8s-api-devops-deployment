resource "random_id" "project" {
  byte_length = 2
}


resource "google_project" "staging" {
  name            = var.project_name
  project_id      = "${var.project_name}-${random_id.project.dec}"
  billing_account = var.billing_account_id
  org_id          = var.org_id

  deletion_policy = "DELETE"
}

locals {
  project_id = google_project.staging.project_id
}

resource "google_project_service" "apis" {
  project = local.project_id

  for_each = toset(var.apis)
  service  = each.key

  disable_on_destroy = false
}
