# Enable Ray Operator on GKE Autopilot Cluster

Enable the Ray Operator add-on on the Google Kubernetes Engine (GKE) Autopilot cluster. This allows managing Ray clusters (head and worker nodes) directly on GKE for distributed AI/ML workloads with managed logging and monitoring.

## Notes

- The Ray Operator addon is supported natively in GKE Autopilot and Standard clusters running GKE version `1.30.0-gke.1747000` or later.
- Enabling Ray cluster logging and monitoring integrates with Cloud Logging and Google Cloud Managed Service for Prometheus.
- The dedicated node IAM service account already possesses `roles/logging.logWriter` and `roles/monitoring.metricWriter`, which satisfy Ray logging/metrics export requirements.

## Proposed Changes

### GKE Module (`modules/gke`)

#### [MODIFY] `modules/gke/variables.tf`
- Add input variables:
  - `enable_ray_operator` (bool, default `true`) - Toggles Ray Operator add-on.
  - `enable_ray_cluster_logging` (bool, default `true`) - Toggles Cloud Logging for Ray cluster logs.
  - `enable_ray_cluster_monitoring` (bool, default `true`) - Toggles Managed Prometheus metrics collection.

#### [MODIFY] `modules/gke/main.tf`
- Add `addons_config` block to `google_container_cluster.autopilot_cluster` containing `ray_operator_config` with sub-blocks for logging and monitoring.

#### [MODIFY] `modules/gke/outputs.tf`
- Export `ray_operator_enabled` output indicating whether Ray Operator is active on the cluster.

---

### Root Configuration

#### [MODIFY] `variables.tf`
- Add configurable variables:
  - `enable_ray_operator` (bool, default `true`)
  - `enable_ray_cluster_logging` (bool, default `true`)
  - `enable_ray_cluster_monitoring` (bool, default `true`)

#### [MODIFY] `main.tf`
- Pass Ray Operator configuration variables from root into the `gke` module invocation.

#### [MODIFY] `outputs.tf`
- Output Ray Operator status at the root level.

#### [MODIFY] `terraform.tfvars` & `terraform.tfvars.example`
- Add variable definitions for `enable_ray_operator`, `enable_ray_cluster_logging`, and `enable_ray_cluster_monitoring`.

---

### Documentation

#### [MODIFY] `README.md` & `design.md`
- Update architectural features and quickstart documentation to reflect the Ray Operator add-on integration.

## Verification Plan

### Automated Tests
- Run `terraform validate` to verify HCL syntax and module parameter compatibility.
- Run `terraform fmt -check` to ensure consistent formatting.
- Run `terraform plan` (if GCP credentials / state are accessible) to verify the execution plan.

### Manual Verification
- Verify generated Terraform plan shows the addition of `addons_config.ray_operator_config` to `google_container_cluster.autopilot_cluster`.
