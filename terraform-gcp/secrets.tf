resource "google_service_account" "gke_external_secrets_sa" {
  account_id   = "gke-external-secrets-sa"
  display_name = "Service account for External Secrets Operator"
  project      = local.project_id
}

resource "google_project_iam_member" "external_secrets_sa_secret_access_permission" {
  project = local.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.gke_external_secrets_sa.email}"
}

resource "google_service_account_iam_member" "workload_identity_binding" {
  service_account_id = google_service_account.gke_external_secrets_sa.id
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${local.project_id}.svc.id.goog[external-secrets-system/external-secrets-operator-sa]" // [namespace/k8s service account with annotation]

  depends_on = [google_project_service.apis, module.gke]
}

resource "google_secret_manager_secret" "db_connection_string" {
  project   = local.project_id
  secret_id = "db-connection-string"

  replication {
    auto {}
  }
  deletion_protection = false
}

resource "google_secret_manager_secret" "db_ca_certificate" {
  project   = local.project_id
  secret_id = "db-ca-cert"

  replication {
    auto {}
  }
  deletion_protection = false
}

resource "google_secret_manager_secret" "jwt_secret" {
  project   = local.project_id
  secret_id = "jwt-secret"

  replication {
    auto {}
  }
  deletion_protection = false
}