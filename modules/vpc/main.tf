# VPC Network
#checkov:skip=CKV2_GCP_18:GKE Autopilot automatically provisions and manages all required firewall rules in Google Cloud.
resource "google_compute_network" "vpc" {
  name                    = "${var.prefix}-vpc"
  auto_create_subnetworks = false
  project                 = var.project_id
  routing_mode            = "REGIONAL"
  description             = "Custom VPC network for ${var.prefix} GKE Autopilot environment"
}

# Subnetwork with Secondary Ranges for VPC-Native GKE
resource "google_compute_subnetwork" "subnet" {
  name                     = "${var.prefix}-subnet-${var.region}"
  ip_cidr_range            = var.subnet_cidr
  region                   = var.region
  network                  = google_compute_network.vpc.id
  project                  = var.project_id
  private_ip_google_access = true
  description              = "Primary subnetwork with secondary IP ranges for GKE pods and services"

  secondary_ip_range {
    range_name    = "${var.prefix}-pods-range"
    ip_cidr_range = var.pods_cidr
  }

  secondary_ip_range {
    range_name    = "${var.prefix}-services-range"
    ip_cidr_range = var.services_cidr
  }

  dynamic "log_config" {
    for_each = var.enable_flow_logs ? [1] : []
    content {
      aggregation_interval = "INTERVAL_5_SEC"
      flow_sampling        = 0.5
      metadata             = "INCLUDE_ALL_METADATA"
    }
  }
}

# Cloud Router for Outbound Internet Egress
resource "google_compute_router" "router" {
  name    = "${var.prefix}-router"
  region  = var.region
  network = google_compute_network.vpc.id
  project = var.project_id

  description = "Cloud Router for Cloud NAT managing egress traffic for private GKE nodes"
}

# Cloud NAT Gateway for Private GKE Nodes
resource "google_compute_router_nat" "nat" {
  name                               = "${var.prefix}-nat-gw"
  router                             = google_compute_router.router.name
  region                             = var.region
  project                            = var.project_id
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

