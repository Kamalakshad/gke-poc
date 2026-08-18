output "service_account_email" {
  description = "The email of the created GKE node service account"
  value       = google_service_account.gke_node_sa.email
}

output "service_account_id" {
  description = "The ID of the created GKE node service account"
  value       = google_service_account.gke_node_sa.id
}

output "service_account_name" {
  description = "The fully-qualified name of the created GKE node service account"
  value       = google_service_account.gke_node_sa.name
}
