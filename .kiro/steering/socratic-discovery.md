# Socratic Discovery Workflow

**Purpose**: A conversational pre-workflow that frames the problem properly before entering AI-DLC. Uses the Socratic method to reduce ambiguity, expose hidden constraints, challenge assumptions, and arrive at a well-framed problem statement that feeds directly into AI-DLC's Requirements Analysis.

**Trigger**: Any software development request that is NOT already precise and low-risk. The agent assesses on first contact whether to enter Socratic Discovery or fast-track into AI-DLC.

## When to Enter Socratic Discovery

Enter this workflow when ANY of these apply:
- The request is ambiguous, broad, or underspecified
- Multiple valid interpretations exist
- Success criteria are unstated
- The change could affect production behavior, data integrity, or APIs
- Several plausible solutions exist with materially different trade-offs
- The user appears to be describing symptoms rather than root causes
- The request involves new features, architecture changes, or multi-component work

## When to Skip (Fast-Track to AI-DLC)

Skip directly to AI-DLC when ALL of these apply:
- Request is precise and well-scoped (e.g., pre-documented bug with recommended fix)
- Single clear solution path exists
- Low risk, easily reversible
- Affected files/components are obvious
- No hidden constraints likely

---

## The Socratic Discovery Loop

The workflow is a **conversation**, not a form. No question files. No `[Answer]:` tags. Direct dialogue.

### Phase 1: Restate & Probe (Goal)

**What the agent does:**
1. Restate the user's request in one sentence to confirm understanding
2. Identify the *type* of problem (bug, feature, refactor, exploration, architecture)
3. Ask 1–3 **Goal** questions — the highest-leverage unknowns:
   - "What outcome would make this successful?"
   - "Who is affected by this — users, other agents, ops?"
   - "What's the trigger for doing this now?"

**Exit condition**: The agent can articulate the goal in a single sentence that the user confirms.

### Phase 2: Surface Assumptions & Constraints

**What the agent does:**
1. State 2–4 assumptions the agent is making (explicitly)
2. Ask the user to confirm, reject, or refine each
3. Ask 1–3 **Constraint** questions:
   - "What can't change?" (APIs, schemas, deployment model, timelines)
   - "What's the blast radius if this goes wrong?"
   - "Are there performance/cost/security boundaries?"

**Exit condition**: Assumptions are validated. Constraints are documented.

### Phase 3: Explore Alternatives & Consequences

**What the agent does:**
1. Present 2–4 realistic approaches (not exhaustive — just the ones that matter)
2. For each, state: trade-off, risk, effort
3. Ask 1–2 **Consequence** questions:
   - "If we pick approach X, what breaks or gets harder later?"
   - "What's the cost of being wrong here?"
4. Ask 1 **Alternative** question:
   - "Is there a simpler version of this that solves 80% of the problem?"

**Exit condition**: User has chosen an approach or narrowed to 2 options.

### Phase 4: Define Validation & Scope

**What the agent does:**
1. Ask 1–2 **Validation** questions:
   - "How will we know this worked?"
   - "What's the smallest test that proves the fix/feature is correct?"
2. Propose a scope boundary:
   - "Here's what I think is in scope: [X]. Out of scope: [Y]. Agree?"
3. Summarize the framed problem as a **Problem Statement**

**Exit condition**: User confirms the problem statement.

---

## Output: Problem Statement

At the end of Socratic Discovery, the agent produces a structured problem statement that feeds directly into AI-DLC:

```markdown
## Problem Statement

**Goal**: [One sentence — what we're solving]
**Type**: [Bug fix | Feature | Refactor | Architecture | Exploration]
**Trigger**: [Why now]
**Affected**: [Components, users, systems]
**Constraints**: [What can't change]
**Chosen Approach**: [Selected direction from Phase 3]
**Success Criteria**: [How we'll know it worked]
**Scope**: [In scope] / [Out of scope]
**Risk**: [What could go wrong, blast radius]
```

This statement becomes the input to AI-DLC's Workspace Detection → Requirements Analysis. The AIDLC workflow can then:
- Skip or compress Requirements Analysis questions (problem already framed)
- Use the Problem Statement as the logged "initial user request" in audit.md
- Reference constraints and success criteria throughout Construction

---

## Interaction Rules

1. **Conversational, not procedural** — No question files. No approval gates. Just dialogue.
2. **3 questions max per round** — Never dump 10 questions. Pick the 3 that would most change the outcome.
3. **State assumptions explicitly** — "I'm assuming X. Correct?"
4. **Challenge the user** — "You said X, but the code shows Y. Which is true?"
5. **Compress when clear** — If the user's first response resolves all ambiguity, skip to Phase 4.
6. **Expand when murky** — Multiple rounds of Phase 2–3 are fine for complex problems.
7. **Never pretend clarity** — If something is unclear, say so. Don't paper over it.
8. **Evidence over opinion** — Read code, check logs, inspect state before forming hypotheses.

---

## Integration with AI-DLC

```
User Request
     │
     ▼
┌─────────────────────────┐
│  Socratic Discovery     │  ← Conversational, no files
│  (1–5 turns typical)    │
└────────────┬────────────┘
             │ Problem Statement
             ▼
┌─────────────────────────┐
│  AI-DLC Workflow        │  ← Structured, file-based
│  (Workspace Detection   │
│   → Requirements → ...) │
└─────────────────────────┘
```

**Handoff rules:**
- Socratic Discovery produces the Problem Statement
- AI-DLC logs it as the initial request in audit.md
- Requirements Analysis depth is informed by discovery complexity:
  - If discovery was 1–2 turns → Minimal depth (problem was simple)
  - If discovery was 3–5 turns → Standard depth
  - If discovery was 5+ turns → Comprehensive depth
- AI-DLC does NOT re-ask questions already answered in discovery

---

## Diagnostic Variant (for bugs/incidents)

When the request is a bug or incident, Phase 1–2 shift to **Diagnostic Mode**:

### Phase 1D: Separate Symptoms from Causes
- "What did you observe?" (symptom)
- "What changed recently?" (potential cause)
- "Can you reproduce it? Under what conditions?"

### Phase 2D: Form Hypotheses
- State 2–3 hypotheses ranked by likelihood
- For each, propose the smallest test to confirm/rule out
- Read code, logs, or state to gather evidence before asking the user

Then resume Phase 3–4 as normal (alternatives → validation → scope).

---

## Examples

### Example: Ambiguous Feature Request
**User**: "We need better error handling in the ETL pipeline"

**Phase 1** (Goal):
> You want to improve error handling in the ETL pipeline. A few questions:
> 1. Which errors are you seeing that aren't handled well today — Glue job failures, schema mismatches, or something else?
> 2. What should happen when an error occurs — retry, alert, skip, or halt?
> 3. Is this triggered by a recent incident?

### Example: Pre-Documented Bug (Fast-Track)
**User**: "fix the bug in docs/bug-check-etl-status-name-mismatch.md"

**Assessment**: Pre-documented, single recommended fix, 2 files, low risk → **Skip discovery, fast-track to AI-DLC.**

### Example: Architecture Decision
**User**: "should we move from LakeFS to S3 Tables for versioning?"

**Phase 1** (Goal):
> You're evaluating whether to replace LakeFS with S3 Tables for data versioning. Before I can help:
> 1. What's driving this — cost, operational complexity, or feature gaps in LakeFS?
> 2. What LakeFS features do you actively use today — branching, merge, rollback, ACLs?
> 3. Is this a full replacement or could it be per-domain (some repos on S3 Tables, some on LakeFS)?
