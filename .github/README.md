# GitHub Actions CI/CD Architecture

This repository uses **GitHub Reusable Workflows (`workflow_call`)** and **Google Cloud Workload Identity Federation (WIF)** for secure, keyless Terraform automation.

---

## Workflows Structure

```text
.github/
├── README.md                          # CI/CD & WIF setup guide
└── workflows/
    ├── reusable-terraform-lint.yml    # Reusable: Format, Validate, TFLint, Trivy
    ├── reusable-terraform-plan.yml    # Reusable: OIDC Auth, Backend Init, Plan & PR Comment
    ├── reusable-terraform-apply.yml   # Reusable: OIDC Auth, Backend Init, Apply
    ├── reusable-terraform-destroy.yml # Reusable: OIDC Auth, Guarded Teardown
    ├── pull-request.yml               # Caller: Triggered on PR (Lint -> Plan)
    ├── deploy.yml                     # Caller: Triggered on push to main (Lint -> Apply)
    └── manual-ops.yml                 # Caller: Manual dispatch (Plan / Apply / Destroy)
```

---

## Prerequisites: Google Cloud Workload Identity Federation (WIF)

To enable GitHub Actions to authenticate to GCP without storing long-lived service account keys:

### 1. Create Workload Identity Pool & Provider
```bash
export PROJECT_ID="prj-jmc-devsecops"  
export POOL_NAME="github-actions-pool"
export PROVIDER_NAME="github-provider"
export GITHUB_REPO="<YOUR_GITHUB_ORG_OR_USERNAME>/gke-poc"

# Create WIF Pool
gcloud iam workload-identity-pools create "$POOL_NAME" \
  --project="$PROJECT_ID" \
--location="global" \
  --display-name="GitHub Actions Pool"

# Create OIDC Provider
gcloud iam workload-identity-pools providers create-oidc "$PROVIDER_NAME" \
  --project="$PROJECT_ID" \
  --location="global" \
  --workload-identity-pool="$POOL_NAME" \
  --display-name="GitHub Actions Provider" \
  --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository,attribute.repository_owner=assertion.repository_owner" \
  --attribute-condition="assertion.repository == '$GITHUB_REPO'" \
  --issuer-uri="https://token.actions.githubusercontent.com"
```

### 2. Create Deployer Service Account and Assign Roles
```bash
export SA_NAME="sa-github-terraform"

# Create Service Account
gcloud iam service-accounts create "$SA_NAME" \
  --project="$PROJECT_ID" \
  --display-name="GitHub Actions Terraform Deployer"

# Grant required permissions to manage VPC, IAM, GKE, and GCS State
gcloud projects add-iam-policy-binding "$PROJECT_ID" \
  --member="serviceAccount:$SA_NAME@$PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/container.admin"

gcloud projects add-iam-policy-binding "$PROJECT_ID" \
  --member="serviceAccount:$SA_NAME@$PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/compute.networkAdmin"

gcloud projects add-iam-policy-binding "$PROJECT_ID" \
  --member="serviceAccount:$SA_NAME@$PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/iam.serviceAccountAdmin"

gcloud projects add-iam-policy-binding "$PROJECT_ID" \
  --member="serviceAccount:$SA_NAME@$PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/iam.serviceAccountUser"

gcloud projects add-iam-policy-binding "$PROJECT_ID" \
  --member="serviceAccount:$SA_NAME@$PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/resourcemanager.projectIamAdmin"

# Grant GCS State Bucket access
gcloud storage buckets add-iam-policy-binding "gs://gcs-jac-tfstate" \
  --member="serviceAccount:$SA_NAME@$PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/storage.objectAdmin"
```

### 3. Allow GitHub Repository to Impersonate the Service Account
```bash
export PROJECT_NUMBER=$(gcloud projects describe "$PROJECT_ID" --format="value(projectNumber)")

gcloud iam service-accounts add-iam-policy-binding "$SA_NAME@$PROJECT_ID.iam.gserviceaccount.com" \
  --project="$PROJECT_ID" \
  --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/projects/$PROJECT_NUMBER/locations/global/workloadIdentityPools/$POOL_NAME/attribute.repository/$GITHUB_REPO"
```

---

## GitHub Repository Secrets Configuration

Navigate to **GitHub Repo -> Settings -> Secrets and variables -> Actions** and add:

| Secret Name | Example Value | Description |
| :--- | :--- | :--- |
| `GCP_WORKLOAD_IDENTITY_PROVIDER` | `projects/1234567890/locations/global/workloadIdentityPools/github-actions-pool/providers/github-provider` | Full resource name of the WIF OIDC provider |
| `GCP_SERVICE_ACCOUNT` | `sa-github-terraform@prj-jmc-devsecops.iam.gserviceaccount.com` | Deployment Service Account email |

---

## Workflow Triggers

1. **Pull Requests (`pull-request.yml`)**:
   - Triggers on PR targeting `main`.
   - Runs `reusable-terraform-lint.yml` (checks formatting, validation, TFLint, and Trivy security scans).
   - Runs `reusable-terraform-plan.yml` (generates speculative plan and adds sticky comment with output on PR).

2. **Main Branch Merges (`deploy.yml`)**:
   - Triggers on push / merge to `main`.
   - Runs `reusable-terraform-lint.yml` and `reusable-terraform-apply.yml`.

3. **Manual Operations (`manual-ops.yml`)**:
   - In GitHub Actions tab, select **Ops - Manual Infrastructure Pipeline**.
   - Choose action (`plan`, `apply`, or `destroy`).
   - If choosing `destroy`, type `DESTROY` in the confirmation box.
