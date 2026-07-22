# Dependencies

## Python Dependencies (requirements.txt)

| Package | Version | Purpose |
|---------|---------|---------|
| boto3 | 1.35.14 | AWS SDK for Python — used in Lambda functions |
| botocore | 1.35.14 | Low-level AWS SDK (boto3 dependency) |
| jmespath | 1.0.1 | JSON query language (boto3 dependency) |
| python-dateutil | 2.9.0.post0 | Date parsing (botocore dependency) |
| s3transfer | 0.10.2 | S3 transfer utilities (boto3 dependency) |
| setuptools | 72.1.0 | Package build tooling |
| six | 1.16.0 | Python 2/3 compatibility (legacy dependency) |
| urllib3 | 2.2.2 | HTTP library (botocore dependency) |
| wheel | 0.43.0 | Package distribution format |

## Terraform Provider Dependencies

| Provider | Source | Version Constraint |
|----------|--------|-------------------|
| AWS | hashicorp/aws | Not pinned (uses latest) |

## AWS Service Dependencies

| Dependency | Type | Notes |
|-----------|------|-------|
| S3 Bucket (output) | Pre-existing | Must exist before deployment — not created by Terraform |
| Amazon Transcribe | Service availability | Must be available in target region |
| Amazon Bedrock | Model access | Claude v2 model access must be enabled in the account |
| IAM | Service-linked roles | Step Functions and Lambda service principals |

## Inter-Module Dependencies

```
environments/dev/main.tf
    │
    ├──▶ modules/step_functions
    │       └── Requires: lambda_function_arn, output_bucket_name
    │
    └──▶ modules/lambda_functions
            └── Requires: transcription_output_bucket
```

**Note**: The dev environment currently hardcodes a Lambda ARN in the step_functions module input (`arn:aws:lambda:us-west-2:123456789012:function:MyTranscriptionProcessor`) rather than wiring the output of the lambda_functions module. This is a wiring gap — the two modules are not connected.

## Known Issues with Dependencies

1. **Circular reference gap**: The step_functions module expects a `lambda_function_arn` input, but the lambda_functions module creates the functions. The dev environment hardcodes a placeholder ARN instead of wiring `module.lambda_functions.process_transcription_function_arn`.
2. **No S3 bucket resource**: The output bucket is referenced by name but never created by any Terraform resource.
3. **No Terraform backend**: State is stored locally — not suitable for team collaboration.
4. **Python runtime 3.9**: Approaching end of standard support — should be upgraded.
5. **Unpinned AWS provider**: Could lead to breaking changes on provider updates.
