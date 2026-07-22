---
name: kiro-skills-best-practices
version: 1.0.0
description: "Kiro Agent Skills: Best practices for creating, structuring, and scoping skills. Use when building or reviewing SKILL.md files."
metadata:
  category: "reference"
---

# Kiro Agent Skills — Best Practices

> **Full reference:** See `references/kiro-skills-docs.md` for complete documentation from kiro.dev.

## Quick Reference

### Skill Structure

```
my-skill/
├── SKILL.md           # Required — instructions and frontmatter
├── scripts/           # Optional — executable code
├── references/        # Optional — documentation
└── assets/            # Optional — templates
```

### Frontmatter (required fields)

```yaml
---
name: my-skill          # Must match folder name. Lowercase, numbers, hyphens only (max 64 chars).
description: "..."      # When to activate. Matched against requests (max 1024 chars).
---
```

Optional: `license`, `compatibility`, `metadata`.

### Best Practices

1. **Write precise descriptions** — Include specific keywords. "Review pull requests for security and test coverage" beats "helps with code review."
2. **Keep SKILL.md focused** — Put detailed docs in `references/` files.
3. **Use scripts for deterministic tasks** — Validation, file generation, API calls.
4. **Choose the right scope** — Global (`~/.kiro/skills/`) for personal workflows, workspace (`.kiro/skills/`) for team procedures.

### Skills vs Steering vs Powers

- **Skills** — Portable packages (open standard). Load on-demand, can include scripts.
- **Steering** — Kiro-specific context. Supports `always`, `auto`, `fileMatch`, `manual` modes.
- **Powers** — Bundle MCP tools with knowledge and workflows. Activate dynamically.

Full specification: https://agentskills.io/specification
