# Dedicated GKE Node Service Account
resource "google_service_account" "gke_node_sa" {
  account_id   = "${var.prefix}-${var.service_account_id}"
  display_name = "${var.prefix} GKE Node Dedicated Service Account"
  project      = var.project_id
  description  = "Least-privilege service account assigned to GKE cluster nodes"
}

locals {
  # Least-privilege roles required for GKE node runtime
  default_node_roles = [
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
    "roles/stackdriver.resourceMetadata.writer",
    "roles/artifactregistry.reader"
  ]

  all_node_roles = distinct(concat(local.default_node_roles, var.additional_roles))
}

# Bind Least-Privilege IAM Roles to the Service Account
resource "google_project_iam_member" "node_sa_roles" {
  for_each = toset(local.all_node_roles)

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.gke_node_sa.email}"
}

# Grant deployer permission to use and attach this service account to GKE nodes
resource "google_service_account_iam_member" "sa_user_deployer" {
  service_account_id = google_service_account.gke_node_sa.name
  role               = "roles/iam.serviceAccountUser"
  member             = "user:kd@jomcy.altostrat.com"
}

