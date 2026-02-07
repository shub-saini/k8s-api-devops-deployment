variable "region" {
  type    = string
  default = "us-central1"
}

variable "zone" {
  type    = string
  default = "us-central1-f"
}

variable "project_name" {
  type    = string
  default = "staging"
}

variable "org_id" {
  type    = string
  default = "709498044594"
}

variable "billing_account_id" {
  type    = string
  default = "01B75F-9B21A3-655BD2"
}

variable "apis" {
  type = list(string)
  default = [
    "compute.googleapis.com",
    "container.googleapis.com",
    "logging.googleapis.com",
    "secretmanager.googleapis.com",
    "storage.googleapis.com",
    "artifactregistry.googleapis.com",
    "sqladmin.googleapis.com",
    "servicenetworking.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
  ]
}

variable "container_registry_repository_id" {
  description = "ID of the Artifact Registry repository"
  type        = string
  default     = "staging-images"
}

variable "vpc_name" {
  type    = string
  default = "staging-vpc"
}
