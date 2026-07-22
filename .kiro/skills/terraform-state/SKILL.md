---
name: terraform-state
description: "Inspect, parse, and analyze Terraform state and plan files via the Terraform CLI. Use when auditing infrastructure, discovering managed resources, detecting drift, comparing planned changes, or inventorying what Terraform manages in an AWS account. Triggers on: 'terraform state', 'what resources are in terraform', 'show terraform plan', 'terraform drift', 'audit terraform', 'inspect infrastructure', 'list terraform resources'."
metadata:
  version: "1.0.0"
  category: "infrastructure"
  requires:
    bins: ["terraform"]
---

# Terraform State & Plan Inspection

Inspect, parse, and analyze Terraform state and plan output using the Terraform CLI. Provides structured access to managed resources, modules, provider versions, planned changes, and drift detection.

## When to Activate

- "terraform state" / "what's in terraform state"
- "list terraform resources"
- "show terraform plan"
- "terraform drift" / "what changed outside terraform"
- "audit terraform" / "inspect infrastructure"
- "what does terraform manage"
- "compare terraform state to AWS"
- "terraform provider versions"
- Infrastructure discovery for migration planning

## Prerequisites

- `terraform` CLI installed and on PATH
- Working directory contains `.tf` files or access to a state file
- AWS credentials configured (for state backends and plan execution)
- For remote state (S3 backend): appropriate IAM permissions

## Commands

### 1. List All Managed Resources

Quick inventory of everything Terraform manages.

```bash
terraform state list
```

Filter by resource type:
```bash
terraform state list | grep "aws_instance"
terraform state list | grep "module\."
```

Count resources by type:
```bash
terraform state list | sed 's/\[.*//;s/\..*\./\./' | sort | uniq -c | sort -rn
```

### 2. Full State as JSON (Primary Discovery Tool)

Machine-readable export of all resources, their attributes, and module structure.

```bash
terraform show -json > /tmp/tf-state.json
```

Parse with jq:
```bash
# List all resource types and counts
cat /tmp/tf-state.json | jq -r '.values.root_module.resources[].type' | sort | uniq -c | sort -rn

# List all resources with their addresses
cat /tmp/tf-state.json | jq -r '.values.root_module.resources[] | "\(.address) (\(.type))"'

# Get all child modules
cat /tmp/tf-state.json | jq -r '.values.root_module.child_modules[]?.address'

# Find resources in child modules (recursive)
cat /tmp/tf-state.json | jq -r '
  [.values.root_module.resources[], 
   (.values.root_module.child_modules[]?.resources[]? // empty)] 
  | .[] | "\(.address) → \(.type)"'

# Extract specific resource values
cat /tmp/tf-state.json | jq '.values.root_module.resources[] | select(.type == "aws_vpc") | .values'

# Find all IAM roles
cat /tmp/tf-state.json | jq -r '
  [.values.root_module.resources[], 
   (.values.root_module.child_modules[]?.resources[]? // empty)] 
  | .[] | select(.type == "aws_iam_role") | "\(.address): \(.values.name)"'

# Find all security groups
cat /tmp/tf-state.json | jq -r '
  [.values.root_module.resources[], 
   (.values.root_module.child_modules[]?.resources[]? // empty)] 
  | .[] | select(.type == "aws_security_group") | "\(.address): \(.values.name) (\(.values.vpc_id))"'
```

### 3. Show a Specific Resource

Human-readable detail for one resource:
```bash
terraform state show aws_instance.example
terraform state show 'module.vpc.aws_subnet.private[0]'
```

### 4. Generate and Inspect a Plan

Create a plan and output as JSON for analysis:
```bash
terraform plan -out=tfplan
terraform show -json tfplan > /tmp/tf-plan.json
```

Parse planned changes:
```bash
# List all resource changes with actions
cat /tmp/tf-plan.json | jq -r '.resource_changes[] | "\(.address): \(.change.actions | join(", "))"'

# Show only creates
cat /tmp/tf-plan.json | jq '.resource_changes[] | select(.change.actions == ["create"]) | .address'

# Show only destroys (DANGEROUS — review carefully)
cat /tmp/tf-plan.json | jq '.resource_changes[] | select(.change.actions | contains(["delete"])) | .address'

# Show updates with what changed
cat /tmp/tf-plan.json | jq '.resource_changes[] | select(.change.actions == ["update"]) | {address, before: .change.before, after: .change.after}'

# Detect drift (resources changed outside TF)
cat /tmp/tf-plan.json | jq '.resource_drift[]? | "\(.address): \(.change.actions | join(", "))"'
```

### 5. Provider Version Audit

```bash
# List providers and versions
terraform providers

# Lock file versions (exact)
cat .terraform.lock.hcl | grep -A2 "provider"

# Required versions from config
grep -r "required_providers" *.tf
grep -r "required_version" *.tf
```

### 6. Module Inventory

```bash
# List all modules used
terraform get -update=false 2>&1 | head -20

# Module sources from config
grep -r "source" *.tf | grep "module"

# Module versions
grep -A5 "module " *.tf | grep -E "(source|version)"
```

### 7. Output Values

```bash
# List all outputs
terraform output -json > /tmp/tf-outputs.json

# Get specific output
terraform output -raw vpc_id
```

### 8. Cross-Reference with AWS CLI (Drift Detection)

Find resources in AWS that are NOT in Terraform state:

```bash
# Get all EC2 instances from AWS
aws ec2 describe-instances --query 'Reservations[].Instances[].InstanceId' --output text > /tmp/aws-instances.txt

# Get all EC2 instances from Terraform
terraform state list | grep "aws_instance" | xargs -I{} terraform state show {} 2>/dev/null | grep "id " | awk '{print $3}' > /tmp/tf-instances.txt

# Find instances in AWS but NOT in Terraform (unmanaged)
comm -23 <(sort /tmp/aws-instances.txt) <(sort /tmp/tf-instances.txt)
```

Similar pattern for security groups, IAM roles, S3 buckets, etc.

## JSON State Structure Reference

See `references/json-format.md` for the complete Terraform JSON output format documentation.

Key paths in `terraform show -json` output:

| JSON Path | Content |
|---|---|
| `.values.root_module.resources[]` | Top-level resources |
| `.values.root_module.child_modules[]` | Module instances |
| `.values.root_module.child_modules[].resources[]` | Resources inside modules |
| `.values.root_module.resources[].type` | Resource type (e.g., `aws_vpc`) |
| `.values.root_module.resources[].values` | All attribute values |
| `.values.root_module.resources[].provider_name` | Provider responsible |
| `.values.outputs` | Root module outputs |

Key paths in `terraform show -json <plan>` output:

| JSON Path | Content |
|---|---|
| `.resource_changes[]` | All planned resource changes |
| `.resource_changes[].change.actions` | `["create"]`, `["update"]`, `["delete"]`, etc. |
| `.resource_changes[].change.before` | Current state values |
| `.resource_changes[].change.after` | Planned state values |
| `.resource_drift[]` | Resources that changed outside Terraform |
| `.configuration.root_module` | Parsed configuration (expressions, references) |

## Tips

- Always run `terraform init` before state commands if working in a new directory
- Use `terraform show -json` (not `terraform state show`) for programmatic parsing
- For large states, pipe through `jq` to filter — full state JSON can be 100MB+
- Remote state (S3 backend) requires `terraform init` to configure the backend
- `terraform plan` with `-refresh-only` detects drift without proposing changes
- `terraform state pull` retrieves raw state JSON from remote backend without local init
- Sensitive values in state are NOT redacted in JSON output — handle carefully
