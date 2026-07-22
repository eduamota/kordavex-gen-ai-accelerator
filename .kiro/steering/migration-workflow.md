# Kordavex GenAI Accelerator — Infrastructure Workflow

<!-- STEERING: This file overrides core-workflow.md for this project. -->
<!-- ACTIVATION: Always active when the project is opened. -->
<!-- SKILLS: Load .kiro/skills/ for component versions and operational patterns. -->
<!-- STEERING: Load .kiro/steering/terraform-team-workflow.md for TF practices. -->

> For: Kordavex Platform Team | Combined AI-DLC adaptive methodology + infrastructure development

---

## How This Workflow Operates

This is an **adaptive, structured process** for building and evolving the Kordavex GenAI Accelerator infrastructure. It combines systematic infrastructure planning with collaborative decision-making at every step.

### Core Principles

1. **Adaptive depth** — Simple decisions get light treatment. Complex, risky decisions get full analysis. The process scales to the problem.
2. **Socratic, not prescriptive** — We surface trade-offs and ask targeted questions. The team makes decisions.
3. **Evidence over opinion** — We read state, inspect infrastructure, and check metrics before making claims. No assumptions without verification.
4. **Structured artifacts** — Every stage produces specific deliverables that carry forward. Nothing is lost between sessions.
5. **Approval gates** — The team reviews and approves before we advance. Nothing is applied without consensus.
6. **Session continuity** — Work resumes exactly where it left off. State is tracked explicitly.

### Interaction Modes

Each stage uses the interaction mode that fits its purpose:

| Mode | Behavior | Used In |
|------|----------|---------|
| **Discovery** | Ask clarifying questions, map options, expose trade-offs before proposing solutions | Requirements, Architecture, Module Planning |
| **Diagnostic** | Separate symptoms from causes, inspect infrastructure, form hypotheses with evidence | Infrastructure Discovery, Baseline Capture |
| **Delivery** | State assumptions briefly, then produce artifacts | IaC Generation, Pipeline Generation |
| **Review** | Evaluate correctness, highlight risks, suggest improvements in priority order | Validation, Approval Gates |

### Depth Adaptation

Each stage adapts its detail level based on:
- **Problem complexity** — single Lambda vs. multi-step pipeline with orchestration
- **Risk level** — dev environment vs. production-facing API
- **Available context** — first session vs. third iteration with full discovery artifacts
- **Team preference** — some decisions are obvious, others need deep exploration

Simple decisions get 1–2 questions. Complex decisions get full analysis with options, consequences, and validation criteria.

---

## Session Continuity

### Starting a New Session

When resuming work, we will:
1. Review current state (which stage, what's been completed)
2. Load all prior artifacts for context
3. Confirm the next step with the team
4. Pick up exactly where we left off

### State Tracking

Progress is tracked in `aidlc-state.md`:

```
Infrastructure State
────────────────────
Project: Kordavex GenAI Accelerator
Current Phase: [Discovery / Construction / Operations]
Current Stage: [stage name]
Last Session: [date]

Discovery Phase
  [ ] Infrastructure Discovery
  [ ] Baseline Capture
  [ ] Infrastructure Requirements
  [ ] Target Architecture Design
  [ ] Module Planning

Construction Phase
  Module 0: Foundation (S3, IAM, Backend)
    [ ] Infrastructure Design
    [ ] IaC Generation
    [ ] Validation
  Module 1: Compute (Lambda, Step Functions)
    [ ] Infrastructure Design
    [ ] IaC Generation
    [ ] Validation
  Module 2: AI Services (Bedrock, Transcribe)
    [ ] Infrastructure Design
    [ ] IaC Generation
    [ ] Validation

Operations Phase
  [ ] Deployment Pipeline
  [ ] Monitoring & Alerting
  [ ] Multi-Environment Promotion
```

---

## Socratic Discovery (Entry Point)

Before entering the structured stages, every major decision starts with a focused conversation:

1. **Restate and probe** — Confirm the goal in one sentence. Ask 1–3 high-value questions.
2. **Surface assumptions** — State what we're assuming explicitly. Team confirms or corrects.
3. **Explore alternatives** — Present 2–3 realistic approaches with trade-offs.
4. **Define validation** — "How will we know this worked?" Propose scope boundaries.

For this accelerator specifically:
- "What's the target audience — internal teams, customers, or a demo?"
- "What does success look like — working pipeline in dev, or multi-environment production-ready?"
- "What absolutely cannot change?" (APIs, security boundaries, compliance requirements)
- "What's the blast radius if a deployment fails?"

---

## Discovery Phase

### Stage 1: Infrastructure Discovery

**Interaction mode:** Diagnostic  
**Depth:** Comprehensive (understand the full current state)

**What we do:**
1. Parse existing Terraform modules and configuration
2. Audit Terraform configuration (backend, providers, modules)
3. Map AWS services in use (Lambda, Step Functions, S3, Transcribe, Bedrock)
4. Document the current pipeline flow
5. Identify gaps (missing resources, hardcoded values, security issues)
6. Document IAM roles and policies
7. Assess environment readiness (dev/staging/prod)

**Deliverables:**
- `service-inventory.md` — every AWS resource and its purpose
- `architecture-current.md` — current state diagram and flow
- `state-audit.md` — TF state health, provider versions, module inventory
- `gap-analysis.md` — what's missing or needs fixing

**Approval gate:** Team confirms artifacts are accurate.

---

### Stage 2: Baseline Capture

**Interaction mode:** Diagnostic  
**Depth:** Standard

**What we do:**
1. Document current cost (estimated or actual if deployed)
2. Identify performance characteristics (Lambda cold start, Transcribe latency)
3. Document current scaling behavior
4. Define explicit success criteria for improvements

**Deliverables:**
- `performance-baseline.md`
- `cost-baseline.md`
- `success-criteria.md` — explicit pass/fail gates

**Approval gate:** Team confirms thresholds and success criteria.

---

### Stage 3: Infrastructure Requirements

**Interaction mode:** Discovery  
**Depth:** Adaptive

**What we do:**
1. Document hard constraints (region, compliance, cost limits)
2. Define security requirements (encryption at rest/in transit, least-privilege IAM)
3. Define networking requirements (VPC vs. public, endpoints)
4. Define observability requirements (logging, tracing, alarms)
5. Define multi-environment strategy (dev → staging → prod)
6. Define CI/CD requirements

**Deliverables:**
- `constraints.md` — hard boundaries
- `nfr-matrix.md` — non-functional requirements by category

**Approval gate:** Team confirms all constraints captured.

---

### Stage 4: Target Architecture Design

**Interaction mode:** Discovery then Delivery  
**Depth:** Comprehensive

**What we do:**
1. Design the target module structure
2. Design IAM roles with least-privilege
3. Design S3 bucket strategy (encryption, lifecycle, access)
4. Design Step Functions workflow (error handling, retries, timeouts)
5. Design Lambda configuration (runtime, memory, timeout, layers)
6. Design Bedrock integration (model selection, guardrails)
7. Design observability stack (CloudWatch, X-Ray, alarms)
8. Produce target architecture diagram

**Deliverables:**
- `target-architecture.md`
- `module-design.md`
- `security-design.md`
- `observability-design.md`
- Architecture diagram

**Approval gate:** Team approves architecture choices.

---

### Stage 5: Module Planning

**Interaction mode:** Discovery then Delivery  
**Depth:** Comprehensive

**What we do:**
1. Group resources into logical Terraform modules
2. Define module interfaces (inputs/outputs)
3. Define dependency ordering
4. Define per-module validation criteria
5. Plan environment promotion strategy

**Deliverables:**
- `module-plan.md` — overview with dependency graph
- Per-module interface specs

**Approval gate:** Team approves module structure before construction begins.

---

## Construction Phase (per-module loop)

Each module completes fully (design, generate, validate) before the next begins.

### Stage 6: Module Infrastructure Design

**Interaction mode:** Discovery then Delivery  
**Depth:** Adaptive per module

**What we do per module:**
1. Define Terraform resources needed
2. Design IAM policies (least-privilege)
3. Define variables and outputs
4. Design error handling and retries
5. Plan testing approach

**Deliverables:**
- `module-N/infrastructure-design.md`
- `module-N/iam-design.md`

**Approval gate:** Team approves design before we generate IaC.

---

### Stage 7: IaC Generation

**Interaction mode:** Delivery  
**Depth:** Comprehensive (generated code must be production-ready)

**Code quality rules enforced on all generated IaC:**
- All resources tagged (Environment, Team, Service, ManagedBy)
- IAM policies follow least-privilege (no `Resource: "*"` without justification)
- S3 buckets encrypted, versioned, with lifecycle policies
- Lambda functions use current Python runtime (3.12+)
- Step Functions include Catch/Retry blocks
- Terraform provider versions pinned
- Backend configured with S3 + KMS encryption
- Variables validated with `validation {}` blocks where appropriate

**Approval gate:** Team reviews generated code.

---

### Stage 8: Validation

**Interaction mode:** Review  
**Depth:** Comprehensive

**Terraform validation:**
1. `terraform fmt -check -recursive`
2. `terraform validate`
3. `terraform plan -detailed-exitcode`
4. Security scan (tfsec/checkov)
5. No overly permissive IAM (no `*` resources without documentation)

**Functional validation (after apply to dev):**
6. Step Functions workflow executes end-to-end
7. Lambda functions execute without errors
8. S3 objects written correctly
9. Bedrock invocation returns valid responses
10. CloudWatch logs and metrics flowing

**Pass/fail gate:** Module passes ONLY if:
- Terraform plan clean
- Security scan passes
- Functional tests pass in dev

---

## Operations Phase

### Stage 9: Deployment Pipeline

**Interaction mode:** Delivery

**What we do:**
1. Define CI/CD pipeline (GitHub Actions)
2. Implement environment promotion (dev → staging → prod)
3. Define approval gates between environments
4. Implement automated validation at each stage

**Deliverables:**
- GitHub Actions workflow files
- Environment-specific variable files
- Deployment runbook

---

### Stage 10: Monitoring & Alerting

**Interaction mode:** Delivery

**What we do:**
1. CloudWatch dashboards for pipeline health
2. Alarms for Lambda errors, Step Functions failures
3. Cost anomaly detection
4. Bedrock usage monitoring

**Deliverables:**
- `monitoring-setup.md`
- Terraform for CloudWatch resources
- Alert routing configuration

---

## Terraform Practices (enforced throughout)

These apply at every Construction and Operations stage:

- **State is remote** — S3 + native locking, KMS encryption, versioning
- **Provider versions pinned** — no floating versions
- **All resources tagged** — Environment, Team, Service, ManagedBy
- **IAM is least-privilege** — scoped to specific resource ARNs
- **Modules are reusable** — clean interfaces, documented variables
- **Environments are isolated** — separate state files, separate AWS accounts if possible
- **Secrets never in code** — use SSM Parameter Store or Secrets Manager

See `terraform-team-workflow.md` for the full Terraform practices reference.

---

## Question and Decision Framework

### When we ask questions

We ask targeted questions when:
- The objective is underspecified
- Non-functional requirements matter (latency, cost, security)
- Several plausible solutions exist with materially different trade-offs
- The change could affect production behavior
- We detect contradictions between documented state and reality

### When we act directly

We move to delivery when:
- The decision is clear and low risk
- The team has explicitly confirmed the direction
- A sensible default exists with no significant downside
- The previous stage's artifacts provide sufficient specification

### Contradiction detection

After receiving answers, we check for:
- Scope mismatch (e.g., "fast timeline" but "comprehensive security review")
- Risk mismatch (e.g., "low risk" but production-facing with PII in audio)
- Technical inconsistency (e.g., "use Bedrock" but model not enabled in region)

If contradictions are detected, we flag them explicitly and ask targeted follow-up questions before proceeding.
