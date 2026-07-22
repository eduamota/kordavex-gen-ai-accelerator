# IaC Tagging — Opt-In

**Extension**: IaC Tagging Strategy

## Opt-In Prompt

The following question is automatically included in the Requirements Analysis clarifying questions when this extension is loaded:

```markdown
## Question: IaC Tagging Extension
Should IaC tagging rules be enforced for this project? When enabled, every infrastructure resource must include mandatory project tags (doit_project, Project_Owner, aws-apn-id).

A) Yes — enforce all TAG rules as blocking constraints (recommended for all AWS customer deployments)
B) No — skip all TAG rules (suitable for local development, PoCs with no AWS billing tracking)
X) Other (please describe after [Answer]: tag below)

[Answer]: 
```
