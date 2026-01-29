locals {
  create_nat = var.cloud_nat != null

  subnet_map = {
    for subnet in var.subnets : subnet.name => google_compute_subnetwork.subnets[subnet.name]
  }
}
