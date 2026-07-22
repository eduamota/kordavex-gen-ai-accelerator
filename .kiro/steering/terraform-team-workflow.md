# Terraform Team Workflow — Kordavex GenAI Accelerator

<!-- STEERING: Loaded by migration-workflow.md at every Construction/Operations stage. -->
<!-- ENFORCEMENT: All rules in this file are HARD CONSTRAINTS on generated IaC. -->

> Practices for managing Terraform for the Kordavex GenAI Accelerator.

---

## 1. Repository Structure

### Modular with Environment Isolation

```
kordavex-gen-ai-accelerator/
├── environments/
│   ├── dev/
│   │   ├── main.tf          ← Root module for dev
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── backend.tf       ← S3 backend config
│   ├── staging/
│   │   └── [mirrors dev structure]
│   └── prod/
│       └── [mirrors dev structure]
├── modules/
│   ├── foundation/          ← S3 buckets, KMS keys, shared IAM
│   ├── lambda_functions/    ← Lambda functions + execution roles
│   └── step_functions/      ← Step Functions state machine + role
├── .github/
│   └── workflows/
│       ├── terraform-plan.yml
│       └── terraform-apply.yml
└── README.md
```

### Why This Structure

| Principle | How It's Applied |
|-----------|-----------------|
| One state file per environment | Each environment has its own backend, own state, own blast radius |
| Modules are reusable | Same modules instantiated across dev/staging/prod with different variables |
| Blast radius is contained | A bad apply in dev can't affect prod |
| Environment promotion is explicit | Changes flow dev → staging → prod via separate applies |

---

## 2. State Management

### Non-Negotiables

1. **Remote state on S3** — encrypted with KMS CMK, versioning enabled
2. **S3-native locking** — `use_lockfile = true` (Terraform 1.10+)
3. **One state file per environment** — never share state across environments
4. **KMS encryption** — SSE-KMS so decryption can be gated via IAM separately
5. **CI/CD as the only path to apply in staging/prod** — no `terraform apply` from laptops on non-dev environments
6. **Versioning for rollback** — corrupted state can be restored from S3 version history

### Backend Configuration (per environment)

```hcl
terraform {
  required_version = ">= 1.10"
  backend "s3" {
    bucket       = "kordavex-terraform-state"
    key          = "dev/terraform.tfstate"
    region       = "us-west-2"
    encrypt      = true
    kms_key_id   = "arn:aws:kms:us-west-2:ACCOUNT:key/KEY_ID"
    use_lockfile = true
  }
}
```

---

## 3. CI/CD Workflow (GitHub Actions)

### Plan on PR, Apply on Merge

```yaml
# .github/workflows/terraform-plan.yml
name: Terraform Plan
on:
  pull_request:
    paths:
      - 'environments/**'
      - 'modules/**'

jobs:
  plan:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        environment: [dev, staging, prod]
    steps:
      - uses: actions/checkout@v4
      - uses: hashicorp/setup-terraform@v3
      - run: |
          cd environments/${{ matrix.environment }}
          terraform init -input=false
          terraform plan -lock-timeout=10m -out=tfplan
      - uses: actions/upload-artifact@v4
        with:
          name: plan-${{ matrix.environment }}
          path: environments/${{ matrix.environment }}/tfplan
```

### Rules

| Rule | Why |
|------|-----|
| Plan on every PR | Catch issues before merge |
| Apply only on merge to main | Controlled deployment |
| Environment matrix | All environments planned simultaneously for visibility |
| Lock timeout always set | Prevent stale lock blocking |

---

## 4. Module Design

### Shared Modules (in `modules/`)

| Module | Purpose | Key Resources |
|--------|---------|---------------|
| `modules/foundation` | Base infrastructure | S3 buckets, KMS keys, shared IAM policies |
| `modules/lambda_functions` | Compute layer | Lambda functions, execution roles, log groups |
| `modules/step_functions` | Orchestration | State machine, execution role, CloudWatch log group |

### Module Interface Design

Keep interfaces small and explicit:

```hcl
# modules/lambda_functions/variables.tf
variable "project_name" {
  description = "Project name prefix for resources"
  type        = string
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]*$", var.project_name))
    error_message = "Project name must be lowercase alphanumeric with hyphens."
  }
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}
```

---

## 5. Code Quality Rules

### Enforced on All Generated IaC

| Rule | Enforcement |
|------|-------------|
| All resources tagged | `Environment`, `Team`, `Service`, `ManagedBy` |
| IAM least-privilege | No `Resource: "*"` without documented justification |
| S3 buckets encrypted | SSE-KMS with versioning and lifecycle policies |
| Lambda uses current runtime | Python 3.12+ (never 3.9 or earlier) |
| Step Functions error handling | Catch and Retry on every Task state |
| Provider versions pinned | Exact version constraints |
| Variables validated | `validation {}` blocks on all user-facing inputs |
| Outputs documented | `description` on every output |

### Naming Convention

```
{project}-{environment}-{resource-type}-{purpose}
```

Examples:
- `kordavex-dev-lambda-process-transcription`
- `kordavex-prod-sfn-audio-processing`
- `kordavex-dev-s3-transcription-output`

---

## 6. Safety Guards

### `prevent_destroy` on Stateful Resources

```hcl
resource "aws_s3_bucket" "transcription_output" {
  bucket = "${var.project_name}-${var.environment}-transcription-output"
  lifecycle { prevent_destroy = true }
}

resource "aws_kms_key" "main" {
  description = "Kordavex encryption key"
  lifecycle { prevent_destroy = true }
}
```

### Lock Timeout in All CI

```bash
terraform plan  -lock-timeout=10m -out=tfplan
terraform apply -lock-timeout=10m tfplan
```

---

## 7. Tagging Convention

```hcl
locals {
  required_tags = {
    Environment = var.environment
    Team        = "kordavex-platform"
    ManagedBy   = "terraform"
    Service     = "gen-ai-accelerator"
    Project     = var.project_name
  }
}
```

---

## 8. PR Conventions

```
feat(foundation): add S3 bucket with encryption and lifecycle
feat(lambda): upgrade runtime to Python 3.12
feat(step-functions): add retry and error handling
fix(iam): scope Bedrock permissions to specific model ARN
chore(ci): add terraform plan workflow
```

### PR Checklist

- [ ] `terraform plan` output reviewed (no unexpected changes)
- [ ] No resources proposed for destruction (unless intentional)
- [ ] IAM policies follow least-privilege
- [ ] All resources tagged
- [ ] Variables have validation blocks
- [ ] Security scan passes (tfsec/checkov)
- [ ] Provider versions pinned
