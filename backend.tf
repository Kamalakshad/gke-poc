terraform {
  backend "gcs" {
    bucket = "gcs-jac-tfstate"
    prefix = "kamal/gke-poc"
  }
}
