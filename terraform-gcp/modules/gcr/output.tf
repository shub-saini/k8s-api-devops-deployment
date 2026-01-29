output "repository_id" {
  description = "The ID of the created repository"
  value       = google_artifact_registry_repository.container_repo.repository_id
}

output "repository_url" {
  description = "The full URL to push/pull images"
  value       = "${var.location}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.container_repo.repository_id}"
}

output "repository_name" {
  description = "The name of the repository"
  value       = google_artifact_registry_repository.container_repo.name
}