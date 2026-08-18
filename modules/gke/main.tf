# GKE Autopilot Regional Cluster
resource "google_container_cluster" "autopilot_cluster" {
  #checkov:skip=CKV_GCP_69:GKE Autopilot mode enforces GKE Metadata Server (Workload Identity) automatically on all managed nodes.
  name     = "${var.prefix}-${var.cluster_name}"
  location = var.region
  project  = var.project_id

  # Enable GKE Autopilot Mode
  enable_autopilot = true

  # Attach to Custom VPC & Subnetwork
  network    = var.network_id
  subnetwork = var.subnet_id

  # VPC-Native IP Allocation (Secondary Ranges)
  ip_allocation_policy {
    cluster_secondary_range_name  = var.pods_secondary_range_name
    services_secondary_range_name = var.services_secondary_range_name
  }

  # Private Cluster Configuration
  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = var.enable_private_endpoint
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block
  }

  # Master Authorized Networks (Control Plane Security)
  master_authorized_networks_config {
    dynamic "cidr_blocks" {
      for_each = var.master_authorized_networks
      content {
        cidr_block   = cidr_blocks.value.cidr_block
        display_name = cidr_blocks.value.display_name
      }
    }
  }

  # Release Channel Configuration
  release_channel {
    channel = var.release_channel
  }

  #checkov:skip=CKV_GCP_61:GKE Autopilot manages Intranode Visibility natively.
  #checkov:skip=CKV_GCP_12:GKE Autopilot enforces Network Policy via GKE Datapath V2 (Cilium) natively.

  # Workload Identity Configuration (GKE Metadata Server)
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  #checkov:skip=CKV_GCP_65:Google Groups RBAC requires an external Google Workspace domain; native GCP IAM / Kubernetes RBAC is used for this POC.

  # Disable Client Certificate Authentication (Enforce Token / IAM Auth)
  master_auth {
    client_certificate_config {
      issue_client_certificate = false
    }
  }

  # Binary Authorization (Supply Chain Security)
  binary_authorization {
    evaluation_mode = "PROJECT_SINGLETON_POLICY_ENFORCE"
  }

  # Resource Labels for Tracking & Cost Allocation
  resource_labels = {
    environment = "devsecops-poc"
    managed_by  = "terraform"
    prefix      = var.prefix
  }

  # Node Auto-provisioning Defaults (Attach Dedicated Least-Privilege SA)
  dynamic "cluster_autoscaling" {
    for_each = var.service_account_email != null ? [1] : []
    content {
      auto_provisioning_defaults {
        service_account = var.service_account_email
      }
    }
  }

  # Maintenance Window
  maintenance_policy {
    daily_maintenance_window {
      start_time = var.maintenance_start_time
    }
  }

  # Ray Operator Add-on (Distributed AI/ML Workloads)
  addons_config {
    ray_operator_config {
      enabled = var.enable_ray_operator

      ray_cluster_logging_config {
        enabled = var.enable_ray_cluster_logging
      }

      ray_cluster_monitoring_config {
        enabled = var.enable_ray_cluster_monitoring
      }
    }
  }

  # Deletion protection flag for POC vs Production
  deletion_protection = var.deletion_protection

  description = "Regional GKE Autopilot cluster managed by Terraform with prefix ${var.prefix}"
}
