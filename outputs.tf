output "project_id" {
  description = "The GCP Project ID where the resources were provisioned"
  value       = var.project_id
}

output "region" {
  description = "The GCP Region where the resources were provisioned"
  value       = var.region
}

# ---------------------------------------------------------------------------------------------------------------------
# VPC & Networking Outputs
# ---------------------------------------------------------------------------------------------------------------------
output "network_name" {
  description = "The name of the provisioned VPC network"
  value       = module.vpc.network_name
}

output "subnet_name" {
  description = "The name of the subnetwork"
  value       = module.vpc.subnet_name
}

output "router_name" {
  description = "The name of the Cloud Router"
  value       = module.vpc.router_name
}

output "nat_gateway_name" {
  description = "The name of the Cloud NAT gateway"
  value       = module.vpc.nat_name
}

# ---------------------------------------------------------------------------------------------------------------------
# IAM Outputs
# ---------------------------------------------------------------------------------------------------------------------
output "gke_node_service_account_email" {
  description = "The email address of the dedicated least-privilege GKE node service account"
  value       = module.iam.service_account_email
}

# ---------------------------------------------------------------------------------------------------------------------
# GKE Autopilot Cluster Outputs
# ---------------------------------------------------------------------------------------------------------------------
output "cluster_name" {
  description = "The name of the GKE Autopilot cluster"
  value       = module.gke.cluster_name
}

output "cluster_id" {
  description = "The unique ID of the GKE Autopilot cluster"
  value       = module.gke.cluster_id
}

output "cluster_endpoint" {
  description = "The endpoint IP of the GKE cluster control plane"
  value       = module.gke.cluster_endpoint
}

output "cluster_ca_certificate" {
  description = "The root CA certificate for the GKE cluster"
  value       = module.gke.cluster_ca_certificate
  sensitive   = true
}

output "kubectl_connection_command" {
  description = "Command to configure kubectl authentication to the GKE Autopilot cluster"
  value       = "gcloud container clusters get-credentials ${module.gke.cluster_name} --region ${var.region} --project ${var.project_id}"
}

output "ray_operator_enabled" {
  description = "Whether the Ray Operator add-on is enabled on the cluster"
  value       = module.gke.ray_operator_enabled
}
