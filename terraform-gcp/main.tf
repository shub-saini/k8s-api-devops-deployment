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

module "vpc" {
  source = "./modules/vpc"

  name       = var.vpc_name
  project_id = local.project_id
  region     = var.region


  subnets = [
    {
      name                     = "public-subnet-1"
      ip_cidr_range            = "10.0.0.0/19"
      private_ip_google_access = true
      secondary_ip_ranges      = []
    },
    {

      name                     = "private-subnet-1" // for gke nodes and db
      ip_cidr_range            = "10.0.32.0/19"
      private_ip_google_access = true
      secondary_ip_ranges = [
        {
          range_name    = "gke-pods"
          ip_cidr_range = "172.16.0.0/14"
        },
        {
          range_name    = "gke-services"
          ip_cidr_range = "172.20.0.0/16"
        }
      ]
    }
  ]

  routes = [
    {
      name             = "default-route"
      dest_range       = "0.0.0.0/0"
      next_hop_gateway = "default-internet-gateway"
    }
  ]

  cloud_nat = {
    name                   = "main-nat"
    nat_ip_allocate_option = "MANUAL_ONLY"
    manual_ip_count        = 1
    nat_subnets = [
      {
        subnet_name : "private-subnet-1"
        source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
      }
    ]
  }

  firewall_rules = [
    # Allow IAP SSH
    {
      name          = "allow-iap-ssh"
      source_ranges = ["35.235.240.0/20"]
      allow = [{
        protocol = "tcp"
        ports    = ["22"]
      }]
    }
  ]

  depends_on = [
    google_project_service.apis, google_project.staging
  ]
}

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
      machine_type   = "e2-medium"
      min_node_count = 2
      max_node_count = 3
      disk_size_gb   = 80
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

module "gcr" {
  source = "./modules/gcr"

  location      = var.region
  project_id    = local.project_id
  repository_id = "stage-images"
  // it create iam binding for gke's service account, so gke can pull images from gcr repo
  gke_service_account = module.gke.node_pool_service_accounts

  depends_on = [google_project_service.apis, module.gke]
}