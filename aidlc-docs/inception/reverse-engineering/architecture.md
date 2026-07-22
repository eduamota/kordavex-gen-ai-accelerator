# Architecture

## High-Level Architecture

The solution follows an **event-driven serverless pipeline** pattern, orchestrated by AWS Step Functions.

```
┌─────────────────────────────────────────────────────────────────────┐
│                        AWS Cloud (us-west-2)                         │
│                                                                      │
│  ┌────────────┐     ┌─────────────────────────────────────────────┐ │
│  │  S3 Bucket │────▶│      Step Functions State Machine            │ │
│  │  (Audio)   │     │                                              │ │
│  └────────────┘     │  StartTranscriptionJob (Transcribe)          │ │
│                     │         │                                     │ │
│                     │         ▼                                     │ │
│                     │  CheckTranscriptionStatus (polling)           │ │
│                     │         │                                     │ │
│                     │         ▼                                     │ │
│                     │  ProcessTranscription (Lambda)                │ │
│                     │         │                                     │ │
│                     │         ▼                                     │ │
│                     │  SummarizeWithBedrock (Bedrock)               │ │
│                     │                                              │ │
│                     └──────────────────────────────────┬────────────┘ │
│                                                        │             │
│  ┌────────────┐     ┌────────────────┐     ┌─────────▼──────────┐  │
│  │  Amazon    │     │  Lambda Fns    │     │  S3 Bucket          │  │
│  │  Transcribe│     │  (Python 3.9)  │     │  (Output/Summaries) │  │
│  └────────────┘     └────────────────┘     └────────────────────┘  │
│                                                                      │
│  ┌────────────────┐                                                  │
│  │ Amazon Bedrock │                                                  │
│  │ (Claude v2)    │                                                  │
│  └────────────────┘                                                  │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

## Architecture Style

- **Pattern**: Serverless orchestration pipeline
- **Orchestration**: AWS Step Functions (state machine)
- **Compute**: AWS Lambda (event-driven, stateless)
- **AI Integration**: Amazon Bedrock (managed LLM inference)
- **Storage**: Amazon S3 (object storage for inputs and outputs)

## Infrastructure as Code

- **Tool**: Terraform
- **Structure**: Modular with environment-based root modules
- **Environments**: dev (configured), staging (placeholder), prod (placeholder)

## Security Model

- IAM roles with assumed trust policies for Step Functions and Lambda
- Lambda has scoped S3 access (GetObject/PutObject on the output bucket)
- Lambda has Bedrock InvokeModel access (currently Resource: *)
- Step Functions role has broad permissions (Resource: * — needs hardening)
