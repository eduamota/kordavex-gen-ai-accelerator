---
name: reflective
description: Self-improvement through in-context session analysis. Scans the current conversation for corrections, workarounds, confirmed patterns, and workflow gaps. Proposes targeted updates to steering files, skills, KB data, or technical improvement docs. Use after any complex session, after explicit corrections ("never do X"), or proactively with "reflect" or "review session".
allowed-tools: Bash(*)
metadata:
  version: "2.0.0"
---

# cos-reflect — Session Analysis & Self-Improvement

Scans the current session for signals that indicate corrections, confirmed patterns, capability gaps, or technical debt. Produces structured proposals for file updates, new skills, KB corrections, or system improvement recommendations. **Proposal-only — never writes without explicit user approval.**

## When to Activatea
- "reflect"
- "review session"
- "what did I learn"
- "what should I improve"
- "analyze this session"
- "cos self-improve"
- Offer to reflect at the end of complex sessions (10+ turns with corrections or multi-system work)

## Non-Goals
- Does not claim access to session history beyond the current context window
- Does not auto-write any file under any circumstances
- Does not propose changes for single-use observations that fail skill-worthiness gates
- Does not mine external systems — works only from what is visible in this conversation

## Instructions

### Step 1: Load Session Telemetry

```bash
mkdir -p tmp
# Read the last 30 turn records from session telemetry
tail -30 tmp/session-metrics.ndjson 2>/dev/null || echo "[]"
```

If the file is missing or empty, continue without turn count — session analysis still runs from in-context turns. Do not fail.

Surface to user: total turns visible in this context window, session start time if available from telemetry.

### Step 2: Scan In-Context Session for Signals

Read all visible turns in the current conversation. Classify each signal by confidence tier:

| Tier | Signal Type | Example Trigger Phrases |
|---|---|---|
| HIGH | Explicit correction | "never", "always", "that's wrong", "stop doing", "don't do that again", "use X not Y", "she is not a", "this is not" |
| MEDIUM | Confirmed success | "perfect", "exactly right", "yes, that's it", "that's what I needed", "keep doing this" |
| MEDIUM | Technical debt | System limitation encountered, manual workaround needed, missing automation identified |
| LOW | Implicit friction | Same request rephrased 2+ times; tool call retried after failure; user added mid-step clarification |

Scope to **current context window only**. Do not speculate about sessions not visible here.

### Step 3: Classify Each Signal to Its Target

For each detected signal, map to its natural home:

| Signal Category | Target File |
|---|---|
| Jira/CBE field usage correction | `.kiro/steering/cbe-field-reference.md` |
| People/role misclassification | `.kiro/steering/cbe-field-reference.md` |
| KB data correction (wrong date, status, info) | Knowledge Graph (direct update) |
| External communication tone/content | `.kiro/steering/kb-sync-discipline.md` |
| GWS field / API / `--fields` error | `.kiro/steering/gws-reference.md` |
| Output format or style preference | `.kiro/steering/exec-brief-style.md` |
| BQ or SFDC query pattern correction | `.kiro/steering/salesforce-reference.md` or skill SKILL.md |
| Risk or blocker protocol correction | `.kiro/steering/risk-protocol.md` |
| DoiT / cloud analytics correction | `.kiro/steering/doit-cloud-analytics-reference.md` |
| New workflow gap (no skill activated) | New `.kiro/skills/cos-<name>/SKILL.md` stub |
| System architecture limitation | `docs/technical-improvements.md` (append) |
| Routing rule correction | `AGENTS.md` routing section |

For **gap signals** (no skill activated, or manual multi-step workaround): proceed to Step 4.
For **technical debt signals**: proceed to Step 4b.
For **correction / preference signals**: skip to Step 5.

### Step 4: Check Skill-Worthiness (Gap Signals Only)

Apply all 5 gates. A new skill proposal is warranted **only if all 5 pass**:

1. **Reusable** — will this pattern recur in future sessions? (not a one-time edge case)
2. **Non-trivial** — absent from existing docs and all current skills?
3. **Specific** — has clear, distinct trigger conditions that won't collide with existing skills?
4. **Verified** — did a working solution actually appear in this session?
5. **Non-duplicative** — no existing skill covers the same workflow?

**If all 5 pass**, draft a complete skill stub:
- **Name:** `cos-<verb>-<noun>` convention, all lowercase, hyphens only
- **Description:** specific enough for Kiro fuzzy-match routing; include 2+ domain nouns
- **Trigger phrases:** 3–5 examples
- **Step outline:** numbered, with MCP tools and output format

Present the full proposed SKILL.md content as a code block. Do not create the file.

### Step 4b: Technical Debt Signals

When a system limitation or missing automation is identified:
- Propose an entry for `docs/technical-improvements.md`
- Include: Problem, Recommendation, Impact
- Assign effort estimate (Low/Medium/High)
- Do NOT create new skills for these — they're architecture changes, not workflows

### Step 5: Generate Reflection Analysis

Present a `Reflection Analysis` block for all detected signals, sorted HIGH → MEDIUM → LOW:

```
## Reflection Analysis — [YYYY-MM-DD] ([N turns visible in context])

─── Signal 1 — HIGH confidence ───────────────────────────────
Source quote: "[exact user phrase]"
Target: [file path or "KB update"]
Proposed change: [description]
Diff preview:
  + [what would be added/changed]

─── Signal 2 — MEDIUM confidence ─────────────────────────────
[...]

─── Summary ───────────────────────────────────────────────────
Signals detected: N (HIGH: X, MEDIUM: Y, LOW: Z)
Proposed changes: M files
KB corrections: K
New skill stubs proposed: J
Technical improvements proposed: T

Apply all? (Y/N/review each)
```

**Hard rule: do not write any file. Present proposals only.**

### Step 6: Apply on Explicit Approval

On `Y`: apply all approved changes in batch.
On `review each`: present one at a time for individual approval.

1. Write the approved diffs to the target files.
2. Execute any KB corrections (update nodes directly).
3. Append a reflection log entry to `tmp/session-metrics.ndjson`:

```bash
TS=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
echo "{\"ts\": \"$TS\", \"type\": \"reflection\", \"signals_detected\": <N>, \"changes_applied\": <M>, \"targets\": [\"<file1>\"], \"signals\": [\"<brief description of each signal>\"]}" >> tmp/session-metrics.ndjson
```

## Output Format

```
## Reflection Analysis — [date] ([N turns visible])

[One block per signal, sorted HIGH → MEDIUM → LOW]
[Each block: source quote, target file, proposed change, diff preview]

─── Summary ───────────────────────────────────────────────────
Signals detected: N (HIGH: X, MEDIUM: Y, LOW: Z)
Proposed changes: M files
KB corrections: K
New skill stubs proposed: J
Technical improvements proposed: T

Apply all? (Y/N/review each)
```

## Tips
- Scope strictly to current context — never speculate about turns not visible
- LOW confidence signals are surfaced for human review only; not auto-proposed
- If `tmp/session-metrics.ndjson` is missing, degrade gracefully — analysis still runs
- The skill-proposal sub-workflow (Step 4) fires only when all 5 gates pass
- Technical debt goes to `docs/technical-improvements.md`, not steering files
- KB corrections are first-class outputs alongside steering/skill changes
- Never propose changes to MCP config or brain spreadsheet schema
- Telemetry now includes signal descriptions for cross-session pattern detection
