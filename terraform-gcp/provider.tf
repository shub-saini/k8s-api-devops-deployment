terraform {
  required_version = ">= 1.14"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.16.0"
    }
  }

  backend "gcs" {
    bucket = "terraform-staging-state-bucket789" // change this manually after bucket creation
    prefix = "envs/staging"
  }
}

provider "google" {
  region = var.region

}

data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = module.gke.cluster_endpoint
  cluster_ca_certificate = module.gke.cluster_ca_certificate
  token                  = data.google_client_config.default.access_token
}

provider "helm" {
  kubernetes = {
    host                   = module.gke.cluster_endpoint
    cluster_ca_certificate = module.gke.cluster_ca_certificate
    token                  = data.google_client_config.default.access_token
  }
}
