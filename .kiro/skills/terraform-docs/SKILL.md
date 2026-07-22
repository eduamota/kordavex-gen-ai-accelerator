---
name: terraform-docs
description: "Search Terraform Registry documentation for providers, modules, and policies. Use when looking up resource schemas, finding module inputs/outputs, checking provider versions, or generating Terraform code with accurate attributes. Triggers on: 'terraform docs', 'terraform provider docs', 'how to configure aws_eks_cluster', 'terraform module inputs', 'latest terraform provider version', 'terraform resource schema', 'EKS terraform module'."
metadata:
  version: "1.0.0"
  category: "infrastructure"
  requires:
    bins: ["docker"]
    note: "Uses the official HashiCorp Terraform MCP Server (hashicorp/terraform-mcp-server) via Docker. No authentication needed for public registry access."
---

# Terraform Registry Documentation Search

Search the Terraform Registry for up-to-date provider resource documentation, module specifications, and policy references. Uses the official HashiCorp Terraform MCP Server to access current schemas rather than relying on training data that may be outdated.

## When to Activate

- "terraform docs" / "terraform documentation"
- "how do I configure [resource]" (e.g., "how do I configure aws_eks_cluster")
- "terraform module for [X]" (e.g., "terraform module for EKS")
- "what inputs does [module] take"
- "latest version of [provider/module]"
- "terraform resource schema for [resource]"
- "what attributes does aws_iam_role have"
- Generating Terraform code and needing accurate attribute names
- Checking if a resource attribute exists in a specific provider version

## Prerequisites

- Docker installed and running (for the MCP server container)
- OR: `hashicorp/terraform-mcp-server` binary on PATH
- Internet access (queries the public Terraform Registry)
- **No authentication needed** for public registry queries

## MCP Server Setup

### Running via Docker (Recommended)

The MCP server runs as a stdio-based container — no network exposure needed:

```json
{
  "servers": {
    "terraform": {
      "command": "docker",
      "args": [
        "run", "-i", "--rm",
        "hashicorp/terraform-mcp-server",
        "--toolsets=registry"
      ]
    }
  }
}
```

### Without Docker (Binary)

Download from [GitHub releases](https://github.com/hashicorp/terraform-mcp-server/releases):

```bash
terraform-mcp-server --toolsets=registry
```

## Available Tools

### Provider Documentation

| Tool | Purpose | Returns |
|---|---|---|
| `search_providers` | Find provider docs by service name or resource | List of docs with IDs, titles, categories |
| `get_provider_details` | Get full docs for a specific resource/data source | Complete markdown documentation |
| `get_latest_provider_version` | Get latest version of a provider | Version string |

### Module Documentation

| Tool | Purpose | Returns |
|---|---|---|
| `search_modules` | Find modules by name or functionality | Module names, descriptions, download counts |
| `get_module_details` | Get complete module info | Inputs, outputs, examples, submodules |
| `get_latest_module_version` | Get latest version of a module | Version string |

### Policy Documentation

| Tool | Purpose | Returns |
|---|---|---|
| `search_policies` | Find Sentinel policies by topic | Policy listings with IDs and descriptions |
| `get_policy_details` | Get detailed policy implementation | Policy code and usage instructions |

## Common Queries

### Looking Up AWS Provider Resources

```
# Find documentation for a specific resource
Tool: search_providers
Input: {
  "provider_name": "aws",
  "provider_namespace": "hashicorp",
  "service_slug": "eks_cluster",
  "provider_document_type": "resources",
  "provider_version": "5.80.0"
}

# Then get the full docs using the providerDocID from the response
Tool: get_provider_details
Input: { "provider_doc_id": "<id_from_search>" }
```

### Finding Module Documentation

```
# Search for EKS modules
Tool: search_modules
Input: { "query": "eks", "namespace": "terraform-aws-modules" }

# Get complete module details
Tool: get_module_details
Input: {
  "module_name": "eks",
  "module_namespace": "terraform-aws-modules",
  "module_provider": "aws",
  "version": "21.24.0"
}
```

### Checking Latest Versions

```
# Latest AWS provider
Tool: get_latest_provider_version
Input: { "provider_name": "aws", "provider_namespace": "hashicorp" }

# Latest EKS module
Tool: get_latest_module_version
Input: {
  "module_name": "eks",
  "module_namespace": "terraform-aws-modules",
  "module_provider": "aws"
}
```

## Use Cases for Migration Work

### 1. Validate Resource Attributes Before Generating TF

When generating Terraform code for EKS, IAM, or VPC resources, query the docs first to ensure attribute names and types are correct for the target provider version.

```
# Before writing aws_eks_cluster resource, verify the schema
search_providers → "eks_cluster" → get_provider_details → read full schema
```

### 2. Check Module Inputs for terraform-aws-modules/eks

```
# Get all inputs and their types for the EKS module
get_module_details → check required vs optional inputs, variable types, defaults
```

### 3. Verify Provider Version Compatibility

```
# Check if a resource exists in a specific provider version
search_providers with provider_version set → if empty result, resource doesn't exist in that version
```

### 4. Find Sentinel Policies for Governance

```
# Find security policies for EKS
search_policies → "eks security" → get relevant policy implementations
```

## Available Resources (Static Guides)

The MCP server also exposes these read-only resources:

| Resource URI | Content |
|---|---|
| `/terraform/style-guide` | Official Terraform code style guide |
| `/terraform/module-development` | Module structure, composition, publishing best practices |
| `/terraform/providers/{namespace}/name/{name}/version/{version}` | Dynamic provider overview docs |

## Toolset Configuration

The server has three toolset groups — only `registry` is needed for doc search:

| Toolset | Purpose | Auth Required |
|---|---|---|
| `registry` | Public Terraform Registry (providers, modules, policies) | **No** |
| `registry-private` | Private TFE/TFC registry | Yes (TFE_TOKEN) |
| `terraform` | HCP Terraform workspace/run management | Yes (TFE_TOKEN) |

For most use cases (CI/CD-based, not HCP Terraform), only `registry` is needed.

## Tips

- Always query docs before generating TF code to avoid schema hallucinations
- Specify the exact `provider_version` when searching — different versions have different attributes
- Use `search_providers` with `provider_document_type: "resources"` for resource blocks, `"data-sources"` for data blocks
- Module docs include examples — use them as starting points for generated code
- The MCP server does NOT read local state files or run terraform commands — use the `terraform-state` skill for that
- No network exposure needed — run via stdio (Docker or binary)
- Rate limiting: 10 requests/second global, 5/session by default
