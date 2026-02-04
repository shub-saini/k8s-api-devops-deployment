output "project_id" {
  value = google_project.staging.project_id
}

output "enabled_apis" {
  description = "List of enabled APIs in the project"
  value       = [for api in google_project_service.apis : api.service]
}

# =============== vpc ===================
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

# =============== k8s cluster ===================
output "cluster_name" {
  value = module.gke.cluster_name
}

output "node_pools" {
  value = module.gke.node_pools
}

output "node_pool_service_accounts" {
  value = module.gke.node_pool_service_accounts
}

output "kubectl_command" {
  value = module.gke.kubectl_command
}

# =============== artifact registry ===================
output "repository_id" {
  value = module.gcr.repository_id
}

output "repository_url" {
  value = module.gcr.repository_url
}

output "repository_name" {
  value = module.gcr.repository_name
}