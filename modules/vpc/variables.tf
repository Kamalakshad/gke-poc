variable "project_id" {
  description = "The GCP project ID where the VPC and networking resources will be created"
  type        = string
}

variable "region" {
  description = "The GCP region for the subnetwork, Cloud Router, and Cloud NAT"
  type        = string
}

variable "prefix" {
  description = "Prefix prepended to all resource names"
  type        = string
  default     = "kd"
}

variable "subnet_cidr" {
  description = "Primary CIDR range for the subnetwork"
  type        = string
  default     = "10.10.0.0/24"
}

variable "pods_cidr" {
  description = "Secondary CIDR range for GKE Pods (Alias IP)"
  type        = string
  default     = "10.20.0.0/16"
}

variable "services_cidr" {
  description = "Secondary CIDR range for GKE Services (ClusterIP)"
  type        = string
  default     = "10.30.0.0/20"
}

variable "enable_flow_logs" {
  description = "Whether to enable VPC Flow Logs on the subnet"
  type        = bool
  default     = false
}
