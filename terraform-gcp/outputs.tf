output "project_id" {
  value = google_project.staging.project_id
}

output "terraform_state_bucket" {
  value = google_storage_bucket.terraform_state_bucket.name
}

output "enabled_apis" {
  description = "List of enabled APIs in the project"
  value       = [for api in google_project_service.apis : api.service]
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "vpc_name" {
  value = module.vpc.vpc_name
}

output "vpc_self_link" {
  value = module.vpc.vpc_self_link
}

output "subnets" {
  value = module.vpc.subnets
}

output "nat_ips" {
  value = module.vpc.nat_ips
}

output "router_name" {
  value = module.vpc.router_name
}

output "router_self_link" {
  value = module.vpc.router_self_link
}

output "firewall_rules" {
  value = module.vpc.firewall_rules
}
