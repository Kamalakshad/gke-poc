output "network_id" {
  description = "The ID of the VPC network"
  value       = google_compute_network.vpc.id
}

output "network_self_link" {
  description = "The URI of the VPC network"
  value       = google_compute_network.vpc.self_link
}

output "network_name" {
  description = "The name of the VPC network"
  value       = google_compute_network.vpc.name
}

output "subnet_id" {
  description = "The ID of the subnetwork"
  value       = google_compute_subnetwork.subnet.id
}

output "subnet_self_link" {
  description = "The URI of the subnetwork"
  value       = google_compute_subnetwork.subnet.self_link
}

output "subnet_name" {
  description = "The name of the subnetwork"
  value       = google_compute_subnetwork.subnet.name
}

output "pods_secondary_range_name" {
  description = "The name of the secondary IP range for Pods"
  value       = google_compute_subnetwork.subnet.secondary_ip_range[0].range_name
}

output "services_secondary_range_name" {
  description = "The name of the secondary IP range for Services"
  value       = google_compute_subnetwork.subnet.secondary_ip_range[1].range_name
}

output "router_name" {
  description = "The name of the Cloud Router"
  value       = google_compute_router.router.name
}

output "nat_name" {
  description = "The name of the Cloud NAT gateway"
  value       = google_compute_router_nat.nat.name
}
