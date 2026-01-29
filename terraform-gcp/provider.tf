provider "google" {
  region = var.region

}

terraform {
  required_version = ">= 1.14"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.16.0"
    }
  }

  backend "gcs" {
    bucket = "staging-50780-tfstate-bucket" // change this manually after bucket creation
    prefix = "terraform/state"
  }
}
