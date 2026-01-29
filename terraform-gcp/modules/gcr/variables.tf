variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "location" {
  description = "Location for the Artifact Registry repository"
  type        = string
}

variable "repository_id" {
  description = "ID of the Artifact Registry repository"
  type        = string
}

variable "gke_service_account" {
  description = "GKE service account email that needs pull access"
  type        = string
}