module "gke" {
  source = "./modules/gke"

  name       = "staging-gke"
  project_id = local.project_id
  zone       = var.zone

  network_self_link             = module.vpc.vpc_self_link
  subnetwork_self_link          = module.vpc.subnets["private-subnet-1"].self_link
  pods_secondary_range_name     = "gke-pods"
  services_secondary_range_name = "gke-services"

  master_ipv4_cidr_block  = "10.0.64.0/28"
  enable_private_cluster  = true
  enable_private_endpoint = false

  node_pools = [
    {
      name           = "default-pool"
      machine_type   = "e2-standard-4"
      min_node_count = 1
      max_node_count = 2
      disk_size_gb   = 100
      disk_type      = "pd-standard"
      spot           = false
    },
  ]

  enable_workload_identity = true
  enable_network_policy    = true
  deletion_protection      = false

  depends_on = [google_project.staging, google_project_service.apis]
}

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = "9.3.7"
}
