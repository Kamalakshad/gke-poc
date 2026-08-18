variable "project_id" {
  description = "The GCP project ID where the GKE cluster will be created"
  type        = string
}

variable "region" {
  description = "The GCP region for the regional GKE Autopilot cluster"
  type        = string
}

variable "prefix" {
  description = "Prefix prepended to all resource names"
  type        = string
  default     = "kd"
}

variable "cluster_name" {
  description = "Name identifier of the GKE cluster"
  type        = string
  default     = "autopilot-cluster"
}

variable "network_id" {
  description = "The VPC network self-link or ID to host the cluster"
  type        = string
}

variable "subnet_id" {
  description = "The subnetwork self-link or ID to host the cluster"
  type        = string
}

variable "pods_secondary_range_name" {
  description = "Name of the secondary range in the subnetwork for Pods"
  type        = string
}

variable "services_secondary_range_name" {
  description = "Name of the secondary range in the subnetwork for Services"
  type        = string
}

variable "master_ipv4_cidr_block" {
  description = "The /28 CIDR block used by the GKE control plane / master network"
  type        = string
  default     = "172.16.0.0/28"
}

variable "enable_private_endpoint" {
  description = "Whether the master's internal IP is used as the cluster endpoint. If false, public endpoint is accessible (with authorized networks)"
  type        = bool
  default     = false
}

variable "master_authorized_networks" {
  description = "List of master authorized network CIDRs allowed to access the control plane"
  type = list(object({
    cidr_block   = string
    display_name = string
  }))
  default = []
}

variable "release_channel" {
  description = "The GKE release channel (REGULAR, RAPID, STABLE, UNSPECIFIED)"
  type        = string
  default     = "REGULAR"
}

variable "deletion_protection" {
  description = "Whether to prevent accidental cluster deletion via Terraform"
  type        = bool
  default     = false
}

variable "service_account_email" {
  description = "The email of the dedicated service account for the cluster nodes"
  type        = string
  default     = null
}

variable "maintenance_start_time" {
  description = "Daily maintenance window start time in UTC format (HH:MM)"
  type        = string
  default     = "03:00"
}

variable "enable_ray_operator" {
  description = "Whether to enable the Ray Operator add-on on the GKE cluster for distributed AI/ML workloads"
  type        = bool
  default     = true
}

variable "enable_ray_cluster_logging" {
  description = "Whether to enable Cloud Logging for Ray cluster head and worker nodes (requires enable_ray_operator = true)"
  type        = bool
  default     = true
}

variable "enable_ray_cluster_monitoring" {
  description = "Whether to enable Managed Service for Prometheus metrics collection for Ray clusters (requires enable_ray_operator = true)"
  type        = bool
  default     = true
}
