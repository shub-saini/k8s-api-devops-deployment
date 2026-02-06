module "gcr" {
  source = "./modules/gcr"

  location      = var.region
  project_id    = local.project_id
  repository_id = "stage-images"
  // it create iam binding for gke's service account, so gke can pull images from gcr repo
  gke_service_account = module.gke.node_pool_service_accounts

  depends_on = [google_project_service.apis, module.gke]
}
