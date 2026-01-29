resource "google_storage_bucket" "terraform_state_bucket" {
  name          = "${google_project.staging.project_id}-tfstate-bucket"
  project       = google_project.staging.project_id
  location      = var.region
  storage_class = "STANDARD"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      num_newer_versions = 10
    }
  }

  # force_destroy               = false
  force_destroy = true

  public_access_prevention    = "enforced"
  uniform_bucket_level_access = true

  depends_on = [google_project_service.apis]
}
