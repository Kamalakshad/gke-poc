variable "project_id" {
  description = "The GCP project ID where the IAM service account and role bindings will be configured"
  type        = string
}

variable "prefix" {
  description = "Prefix prepended to resource names"
  type        = string
  default     = "kd"
}

variable "service_account_id" {
  description = "The account ID for the dedicated GKE node service account"
  type        = string
  default     = "gke-node-sa"
}

variable "additional_roles" {
  description = "Optional additional IAM roles to grant to the dedicated node service account"
  type        = list(string)
  default     = []
}
