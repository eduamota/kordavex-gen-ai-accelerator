# IaC Tagging Rules

## Overview
These tagging rules are MANDATORY cross-cutting constraints that apply to every infrastructure-as-code resource generated or modified by the AI-DLC workflow. They are not optional guidance — they are hard constraints that Infrastructure Design and Code Generation stages MUST enforce.

**Enforcement**: At each applicable stage, the model MUST verify that all IaC resources include the required tags before presenting the stage completion message to the user.

### Blocking Tagging Finding Behavior
A **blocking tagging finding** means:
1. The finding MUST be listed in the stage completion message under a "Tagging Findings" section with the TAG rule ID and description
2. The stage MUST NOT present the "Continue to Next Stage" option until all blocking findings are resolved
3. The model MUST present only the "Request Changes" option with a clear explanation of what needs to change
4. The finding MUST be logged in `aidlc-docs/audit.md` with the TAG rule ID, description, and stage context

If a TAG rule is not applicable to the current stage (e.g., no IaC resources are being generated), mark it as **N/A** in the compliance summary — this is not a blocking finding.

### Default Enforcement
All rules in this document are **blocking** by default. If any rule's verification criteria are not met, it is a blocking tagging finding — follow the blocking finding behavior defined above.

---

## Rule TAG-01: Project Tag

**Rule**: Every IaC resource MUST include a `doit_project` tag that identifies the project.

**Format**: `doit_[customerName]_[projectType]_[YYYYMMDD]`

- `customerName`: The customer's name (lowercase, no spaces)
- `projectType`: The type of engagement (e.g., `csp`, `genai`, `migration`, `modernization`)
- `YYYYMMDD`: The project start date

**Example**: `doit_daysmart_csp_20260324`

**Verification**:
- No IaC resource is defined without a `doit_project` tag
- The tag value follows the `doit_[customerName]_[projectType]_[YYYYMMDD]` format
- The customer name, project type, and date are populated (not placeholder values in generated code)
- During Infrastructure Design, the model MUST ask the user for the `doit_project` value if not already known

---

## Rule TAG-02: Project Owner Tag

**Rule**: Every IaC resource MUST include a `Project_Owner` tag that identifies the customer-side owner, maintainer, or billing responsibility for the project.

**Accepted values** (in order of preference):
1. Department or team alias (e.g., `Platform-Engineering`, `Engineering-Backend`)
2. Cost center code (e.g., `CC-12345`)
3. Team email (e.g., `team@customer.com`)
4. Individual name (not recommended — use only when no team/department identifier exists)

**Verification**:
- No IaC resource is defined without a `Project_Owner` tag
- The tag value identifies the customer-side owner (not a DoiT internal owner)
- During Infrastructure Design, the model MUST ask the user for the `Project_Owner` value if not already known

---

## Rule TAG-03: AWS Partner Revenue Management Tag

**Rule**: Every IaC resource deployed to an AWS account MUST include an `aws-apn-id` tag for AWS Partner Network revenue tracking.

**Accepted values**:
| Value | Description |
|-------|-------------|
| `prod-uqzf6ze27qqo6` | General GenAI Accelerator |
| `prod-6thp4rd5ci5lw` | OpenAI to Bedrock Migration Accelerator |

**Verification**:
- No IaC resource targeting AWS is defined without an `aws-apn-id` tag
- The tag value is one of the accepted values listed above (not a free-form string)
- During Infrastructure Design, the model MUST ask the user which `aws-apn-id` value applies if not already known
- This rule is N/A for non-AWS infrastructure (Azure, GCP, on-premise)
