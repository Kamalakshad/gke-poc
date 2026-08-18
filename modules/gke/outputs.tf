output "cluster_id" {
  description = "The ID of the GKE Autopilot cluster"
  value       = google_container_cluster.autopilot_cluster.id
}

output "cluster_name" {
  description = "The name of the GKE Autopilot cluster"
  value       = google_container_cluster.autopilot_cluster.name
}

output "cluster_endpoint" {
  description = "The IP endpoint of the GKE cluster control plane"
  value       = google_container_cluster.autopilot_cluster.endpoint
}

output "cluster_ca_certificate" {
  description = "The base64 encoded public certificate of the cluster root CA"
  value       = google_container_cluster.autopilot_cluster.master_auth[0].cluster_ca_certificate
  sensitive   = true
}

output "location" {
  description = "The region of the GKE cluster"
  value       = google_container_cluster.autopilot_cluster.location
}

output "operation_mode" {
  description = "The operational mode of the cluster"
  value       = "Autopilot"
}

output "ray_operator_enabled" {
  description = "Whether the Ray Operator add-on is enabled on the cluster"
  value       = var.enable_ray_operator
}
