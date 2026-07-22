# Technology Stack

## Infrastructure as Code

| Technology | Version | Purpose |
|-----------|---------|---------|
| Terraform | >= 1.0 | Infrastructure provisioning and management |
| AWS Provider | (not pinned) | AWS resource management |

## Runtime

| Technology | Version | Purpose |
|-----------|---------|---------|
| Python | 3.9 | Lambda function runtime |
| boto3 | 1.35.14 | AWS SDK for Python (Lambda functions) |

## AWS Services

| Service | Purpose | Integration |
|---------|---------|-------------|
| AWS Step Functions | Workflow orchestration | Terraform resource, SDK integrations |
| AWS Lambda | Custom compute (transcription processing, summarization) | Terraform resource |
| Amazon Transcribe | Speech-to-text | Step Functions native integration |
| Amazon Bedrock (Claude v2) | Text summarization and action item extraction | Step Functions native integration + boto3 |
| Amazon S3 | Storage for audio, transcriptions, processed text, summaries | boto3 SDK |
| AWS IAM | Access control and service roles | Terraform resources |

## Development Tools

| Tool | Purpose |
|------|---------|
| `setup_files.sh` | Project directory scaffolding script |
| `.gitignore` | Git ignore configuration (Terraform state, Python caches, IDE files) |
| `requirements.txt` | Python dependency pinning (boto3 ecosystem) |

## Model Configuration

| Parameter | Current Value | Notes |
|-----------|--------------|-------|
| Bedrock Model ID | `anthropic.claude-v2` | Deprecated — should be updated to a current model |
| Transcribe Language | `en-US` | Configurable via variable |
| Max Tokens (summarize) | 300 | Hardcoded in Lambda function |

## Deployment Model

- **Multi-environment**: dev / staging / prod directory structure
- **Module reuse**: Shared modules instantiated per environment
- **State management**: Not configured (no backend block — defaults to local state)
- **CI/CD**: None defined
