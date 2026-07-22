# Component Inventory

## Terraform Modules

| Module | Path | Purpose | Resources Created |
|--------|------|---------|-------------------|
| `step_functions` | `modules/step_functions/` | Orchestration layer | IAM Role, IAM Policy, Step Functions State Machine |
| `lambda_functions` | `modules/lambda_functions/` | Compute layer | IAM Role, IAM Policies (S3, Bedrock, Basic Execution), 2x Lambda Functions |

## Environment Root Modules

| Environment | Path | Status |
|-------------|------|--------|
| dev | `environments/dev/` | Configured (references both modules) |
| staging | `environments/staging/` | Empty placeholder |
| prod | `environments/prod/` | Empty placeholder |

## Lambda Functions

| Function | File | Runtime | Purpose |
|----------|------|---------|---------|
| `process_transcription` | `modules/lambda_functions/lambda_functions/process_transcription.py` | Python 3.9 | Retrieves raw transcription JSON from S3, extracts clean text, saves as `.txt` |
| `summarize_text` | `modules/lambda_functions/lambda_functions/summarize_text.py` | Python 3.9 | Reads processed text, calls Bedrock (Claude) for summarization, saves summary |

## AWS Services Used

| Service | Usage | Integration Method |
|---------|-------|-------------------|
| Amazon S3 | Audio input storage, transcription output, processed text, summaries | SDK (boto3) via Lambda, SDK integration via Step Functions |
| Amazon Transcribe | Speech-to-text conversion | Step Functions SDK integration (native) |
| Amazon Bedrock | Text summarization and action item extraction | Step Functions SDK integration + boto3 in Lambda |
| AWS Step Functions | Workflow orchestration | Terraform resource |
| AWS Lambda | Custom processing logic | Terraform resource + Python source |
| AWS IAM | Access control | Terraform roles and policies |

## Configuration Variables

| Variable | Default | Used By |
|----------|---------|---------|
| `aws_region` | `us-west-2` | Both modules |
| `step_functions_name` | `AudioProcessingWorkflow` | step_functions module |
| `transcribe_language_code` | `en-US` | step_functions module |
| `bedrock_model_id` | `anthropic.claude-v2` | Both modules |
| `lambda_function_arn` | (required) | step_functions module |
| `output_bucket_name` | (required) | step_functions module |
| `project_name` | `audio-processing` | lambda_functions module |
| `transcription_output_bucket` | (required) | lambda_functions module |

## File Tree

```
kordavex-gen-ai-accelerator/
├── README.md
├── requirements.txt
├── setup_files.sh
├── .gitignore
├── environments/
│   ├── dev/
│   │   ├── main.tf          (root module - configured)
│   │   ├── variables.tf     (empty)
│   │   └── outputs.tf       (empty)
│   ├── staging/
│   │   ├── main.tf          (empty)
│   │   ├── variables.tf     (empty)
│   │   └── outputs.tf       (empty)
│   └── prod/
│       ├── main.tf          (empty)
│       ├── variables.tf     (empty)
│       └── outputs.tf       (empty)
└── modules/
    ├── step_functions/
    │   ├── main.tf           (state machine + IAM)
    │   ├── variables.tf      (inputs)
    │   ├── outputs.tf        (empty)
    │   └── versions.tf       (terraform >= 1.0)
    └── lambda_functions/
        ├── main.tf           (lambdas + IAM)
        ├── variables.tf      (inputs)
        ├── outputs.tf        (ARN outputs)
        ├── versions.tf       (terraform >= 1.0)
        └── lambda_functions/
            ├── process_transcription.py
            └── summarize_text.py
```
