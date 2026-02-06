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

