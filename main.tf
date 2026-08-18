# ---------------------------------------------------------------------------------------------------------------------
# NETWORKING MODULE: Custom VPC, Subnetwork, Cloud Router, and Cloud NAT
# ---------------------------------------------------------------------------------------------------------------------
module "vpc" {
  source = "./modules/vpc"

  project_id       = var.project_id
  region           = var.region
  prefix           = var.prefix
  subnet_cidr      = var.subnet_cidr
  pods_cidr        = var.pods_cidr
  services_cidr    = var.services_cidr
  enable_flow_logs = var.enable_flow_logs
}

# ---------------------------------------------------------------------------------------------------------------------
# IAM MODULE: Dedicated Least-Privilege GKE Node Service Account and Role Bindings
# ---------------------------------------------------------------------------------------------------------------------
module "iam" {
  source = "./modules/iam"

  project_id = var.project_id
  prefix     = var.prefix
}

# ---------------------------------------------------------------------------------------------------------------------
# GKE MODULE: Regional Autopilot Cluster (Private Nodes, VPC-Native)
# ---------------------------------------------------------------------------------------------------------------------
module "gke" {
  source = "./modules/gke"

  project_id                    = var.project_id
  region                        = var.region
  prefix                        = var.prefix
  network_id                    = module.vpc.network_self_link
  subnet_id                     = module.vpc.subnet_self_link
  pods_secondary_range_name     = module.vpc.pods_secondary_range_name
  services_secondary_range_name = module.vpc.services_secondary_range_name
  master_ipv4_cidr_block        = var.master_ipv4_cidr_block
  enable_private_endpoint       = var.enable_private_endpoint
  master_authorized_networks    = var.master_authorized_networks
  release_channel               = var.release_channel
  deletion_protection           = var.deletion_protection
  service_account_email         = module.iam.service_account_email

  # Ray Operator
  enable_ray_operator           = var.enable_ray_operator
  enable_ray_cluster_logging    = var.enable_ray_cluster_logging
  enable_ray_cluster_monitoring = var.enable_ray_cluster_monitoring

  depends_on = [
    module.vpc,
    module.iam
  ]
}
