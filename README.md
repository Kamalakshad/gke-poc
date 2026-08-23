# GKE Autopilot Modular Infrastructure with Terraform

Production-grade modular Terraform codebase to provision a **Google Kubernetes Engine (GKE) Autopilot** cluster and VPC networking on Google Cloud Platform.

- **Project ID**: `prj-jmc-devsecops`
- **Region**: `asia-south1` (Mumbai)
- **Resource Prefix**: `kd`

---

## Architecture Overview

- **Custom VPC (`kd-vpc`)**: Isolated custom-mode VPC network.
- **Subnetwork (`kd-subnet-asia-south1`)**: Primary CIDR `10.10.0.0/24` with secondary Alias IP ranges for Pods (`kd-pods-range` / `10.20.0.0/16`) and Services (`kd-services-range` / `10.30.0.0/20`).
- **Cloud Router & Cloud NAT (`kd-router`, `kd-nat-gw`)**: Outbound NAT gateway providing egress connectivity for private cluster nodes to pull images and reach external APIs.
- **Dedicated Node Service Account (`kd-gke-node-sa`)**: Hardened least-privilege IAM service account assigned to cluster nodes.
- **GKE Autopilot Cluster (`kd-autopilot-cluster`)**: Regional, VPC-native, private cluster with Workload Identity and automated maintenance.
- **Ray Operator Add-on**: Enabled via `addons_config`, providing native GKE support for deploying and managing distributed Ray clusters (head + workers) for AI/ML workloads. Cloud Logging and Managed Prometheus metrics collection are enabled.

---

## Directory Structure

```text
.
├── .github/
│   ├── README.md                # CI/CD & GCP Workload Identity Federation guide
│   └── workflows/
│       ├── reusable-terraform-lint.yml    # Reusable: Format, validate, TFLint & Trivy
│       ├── reusable-terraform-plan.yml    # Reusable: Plan with PR comment
│       ├── reusable-terraform-apply.yml   # Reusable: Apply to environment
│       ├── reusable-terraform-destroy.yml # Reusable: Guarded destroy
│       ├── pull-request.yml               # Caller: CI for PRs
│       ├── deploy.yml                     # Caller: CD for main branch
│       └── manual-ops.yml                 # Caller: Manual dispatch
├── .tflint.hcl                  # TFLint Google ruleset configuration
├── main.tf                      # Root module: orchestrates VPC, IAM, and GKE modules
├── variables.tf                 # Global input variables
├── outputs.tf                   # Root outputs exposing cluster connection details
├── versions.tf                  # Terraform & Google provider constraints
├── terraform.tfvars             # Active configuration values
├── terraform.tfvars.example     # Reference configuration template
├── backend.tf                   # GCS remote state backend configuration
├── backend.tf.example           # GCS remote state backend template
├── design.md                    # Detailed architectural design & IAM matrix
└── modules/
    ├── vpc/                     # Networking Module (VPC, Subnet, Router, NAT)
    ├── iam/                     # Security Module (Dedicated SA, Least-Privilege IAM)
    └── gke/                     # Cluster Module (Regional Autopilot GKE)
```

---

## Prerequisites

1. **Google Cloud SDK (`gcloud`)** installed and authenticated:
   ```bash
   gcloud auth login
   gcloud auth application-default login
   gcloud config set project prj-jmc-devsecops
   ```

2. **Required GCP Services Enabled**:
   ```bash
   gcloud services enable \
     container.googleapis.com \
     compute.googleapis.com \
     iam.googleapis.com \
     logging.googleapis.com \
     monitoring.googleapis.com \
     artifactregistry.googleapis.com
   ```

3. **Required IAM Permissions for Provisioner**:
   Ensure your deploying user or service account has the following IAM roles:
   - `roles/container.admin`
   - `roles/compute.networkAdmin`
   - `roles/iam.serviceAccountAdmin`
   - `roles/iam.serviceAccountUser`
   - `roles/resourcemanager.projectIamAdmin`

---

## Quickstart & Deployment

1. **Initialize Terraform**:
   ```bash
   terraform init
   ```

2. **Validate Syntax & Review Plan**:
   ```bash
   terraform validate
   terraform plan
   ```

3. **Apply Infrastructure**:
   ```bash
   terraform apply
   ```

4. **Connect to GKE Autopilot Cluster**:
   ```bash
   gcloud container clusters get-credentials kd-autopilot-cluster \
     --region asia-south1 \
     --project prj-jmc-devsecops

   kubectl get nodes -o wide
   ```

---

## Estimated Monthly Cost (`asia-south1`)

- **Cluster Management Fee**: **$73.00/mo** (Covered by Google Cloud's **$74.40/mo** free tier credit for 1 cluster).
- **Cloud NAT**: **~$35.10/mo** ($0.045/hr + egress data).
- **GKE Autopilot Workloads**: Pay-per-pod resource usage (~$0.0494/vCPU-hr, ~$0.0054/GB-RAM-hr).
- **VPC, Subnets, Routers, IAM**: **$0.00 (Free)**.

---

## CI/CD Automation (GitHub Actions)

This repository includes a reusable GitHub Actions CI/CD pipeline using **Google Cloud Workload Identity Federation (WIF / OIDC)**:

- **Pull Requests**: Automatically runs formatting check, `terraform validate`, `tflint`, `trivy` security scans, and generates speculative `terraform plan` posted directly to the PR comments.
- **Main Merges**: Automatically executes `terraform apply` when PRs are merged to `main`.
- **Manual Operations**: Trigger plan, apply, or guarded teardown (`destroy`) on demand from GitHub Actions tab.

See [.github/README.md](file:///.github/README.md) for full Workload Identity Federation and GitHub Secrets setup instructions.

