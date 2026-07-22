# Terraform JSON Output Format Reference

Source: https://developer.hashicorp.com/terraform/internals/json-format

## State Representation (`terraform show -json`)

```json
{
  "format_version": "1.0",
  "terraform_version": "1.15.x",
  "values": {
    "outputs": {
      "output_name": {
        "value": "output_value",
        "type": "string",
        "sensitive": false
      }
    },
    "root_module": {
      "resources": [
        {
          "address": "aws_instance.example[1]",
          "mode": "managed",
          "type": "aws_instance",
          "name": "example",
          "index": 1,
          "provider_name": "aws",
          "schema_version": 2,
          "values": {
            "id": "i-abc123",
            "instance_type": "t2.micro"
          },
          "sensitive_values": {
            "id": true
          }
        }
      ],
      "child_modules": [
        {
          "address": "module.child",
          "resources": [
            {
              "address": "module.child.aws_instance.foo",
              "mode": "managed",
              "type": "aws_instance",
              "name": "foo",
              "provider_name": "aws",
              "values": {}
            }
          ],
          "child_modules": []
        }
      ]
    }
  }
}
```

## Plan Representation (`terraform show -json <planfile>`)

```json
{
  "format_version": "1.0",
  "terraform_version": "1.15.x",
  "applyable": true,
  "complete": true,
  "errored": false,

  "prior_state": { "values": { "root_module": { "resources": [] } } },
  "planned_values": { "root_module": { "resources": [] } },

  "resource_changes": [
    {
      "address": "module.child.aws_instance.foo[0]",
      "module_address": "module.child",
      "mode": "managed",
      "type": "aws_instance",
      "name": "foo",
      "index": 0,
      "change": {
        "actions": ["update"],
        "before": { "instance_type": "t2.micro" },
        "after": { "instance_type": "t3.medium" },
        "after_unknown": { "id": true },
        "before_sensitive": {},
        "after_sensitive": {}
      },
      "action_reason": "replace_because_cannot_update"
    }
  ],

  "resource_drift": [
    {
      "address": "aws_security_group.main",
      "type": "aws_security_group",
      "change": {
        "actions": ["update"],
        "before": { "ingress": [] },
        "after": { "ingress": [{"from_port": 443}] }
      }
    }
  ],

  "configuration": {
    "provider_config": {
      "aws": {
        "name": "aws",
        "full_name": "registry.terraform.io/hashicorp/aws",
        "expressions": {
          "region": { "constant_value": "us-west-2" }
        }
      }
    },
    "root_module": {
      "resources": [],
      "module_calls": {}
    }
  },

  "variables": {
    "region": { "value": "us-west-2" }
  },

  "output_changes": {
    "vpc_id": {
      "change": {
        "actions": ["create"],
        "before": null,
        "after": "vpc-abc123"
      }
    }
  }
}
```

## Change Actions

| Action | Meaning |
|---|---|
| `["no-op"]` | No changes needed |
| `["create"]` | Resource will be created |
| `["read"]` | Data source will be read |
| `["update"]` | Resource will be updated in-place |
| `["delete", "create"]` | Resource will be destroyed then recreated |
| `["create", "delete"]` | Resource will be created then old one destroyed |
| `["delete"]` | Resource will be destroyed |

## Action Reasons

| Reason | Meaning |
|---|---|
| `replace_because_tainted` | Object is marked tainted |
| `replace_because_cannot_update` | Provider can't update in-place |
| `replace_by_request` | User requested replacement |
| `delete_because_no_resource_config` | No config for this resource |
| `delete_because_no_module` | Module no longer declared |
| `delete_because_wrong_repetition` | count/for_each mismatch |
| `delete_because_count_index` | Index out of range for count |
| `delete_because_each_key` | Key not in for_each |

## Common jq Patterns

```bash
# All resources (including nested modules) flattened
jq '[.. | .resources? // empty | .[]] | unique_by(.address)'

# Resources by provider
jq '[.. | .resources? // empty | .[]] | group_by(.provider_name) | map({provider: .[0].provider_name, count: length})'

# All VPC-related resources
jq '[.. | .resources? // empty | .[]] | map(select(.type | startswith("aws_vpc") or startswith("aws_subnet") or startswith("aws_security_group")))'

# Module dependency tree
jq '.values.root_module.child_modules[] | {module: .address, resource_count: (.resources | length)}'

# Resources with specific tags
jq '[.. | .resources? // empty | .[]] | map(select(.values.tags? // {} | has("Environment")))'
```

## Remote State Access

```bash
# Pull state from S3 backend without full init
terraform state pull > state.json

# Use with specific backend config
terraform init -backend-config="bucket=my-state-bucket" -backend-config="key=prod/terraform.tfstate"

# Read-only state access (no lock)
terraform state list -state=terraform.tfstate
```
