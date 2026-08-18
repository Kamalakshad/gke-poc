variable "project_id" {
  description = "The GCP project ID to deploy the GKE Autopilot infrastructure into"
  type        = string
  default     = "prj-jmc-devsecops"
}

variable "region" {
  description = "The target GCP region for all regional resources"
  type        = string
  default     = "asia-south1"
}

variable "prefix" {
  description = "Resource prefix applied to all provisioned GCP components"
  type        = string
  default     = "kd"
}

variable "subnet_cidr" {
  description = "Primary CIDR range for the GKE VPC subnetwork"
  type        = string
  default     = "10.10.0.0/24"
}

variable "pods_cidr" {
  description = "Secondary CIDR range allocated for GKE Pods (Alias IP)"
  type        = string
  default     = "10.20.0.0/16"
}

variable "services_cidr" {
  description = "Secondary CIDR range allocated for GKE Services (ClusterIP)"
  type        = string
  default     = "10.30.0.0/20"
}

variable "master_ipv4_cidr_block" {
  description = "The /28 CIDR block reserved for the GKE control plane / master network"
  type        = string
  default     = "172.16.0.0/28"
}

variable "enable_private_endpoint" {
  description = "Whether the master control plane is only accessible via its internal IP address"
  type        = bool
  default     = false
}

variable "master_authorized_networks" {
  description = "List of authorized IP CIDRs permitted to access the GKE control plane"
  type = list(object({
    cidr_block   = string
    display_name = string
  }))
  default = []
}

variable "release_channel" {
  description = "GKE release channel for automated version management (REGULAR, RAPID, STABLE)"
  type        = string
  default     = "REGULAR"
}

variable "deletion_protection" {
  description = "Whether to prevent accidental cluster deletion via Terraform (set to false for POC testing)"
  type        = bool
  default     = false
}

variable "enable_flow_logs" {
  description = "Whether to enable VPC Flow Logs on the subnetwork"
  type        = bool
  default     = false
}

# ---------------------------------------------------------------------------------------------------------------------
# Ray Operator Configuration
# ---------------------------------------------------------------------------------------------------------------------
variable "enable_ray_operator" {
  description = "Whether to enable the Ray Operator add-on on the GKE cluster for distributed AI/ML workloads"
  type        = bool
  default     = true
}

variable "enable_ray_cluster_logging" {
  description = "Whether to enable Cloud Logging for Ray cluster head and worker nodes"
  type        = bool
  default     = true
}

variable "enable_ray_cluster_monitoring" {
  description = "Whether to enable Managed Service for Prometheus metrics collection for Ray clusters"
  type        = bool
  default     = true
}
