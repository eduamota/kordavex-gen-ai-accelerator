# Interaction Diagrams

## Audio Processing Workflow — Sequence Diagram

```
Caller          Step Functions       Transcribe         S3              Lambda              Bedrock
  │                   │                  │              │                 │                   │
  │  Start Execution  │                  │              │                 │                   │
  │  (audioFileUri,   │                  │              │                 │                   │
  │   jobName)        │                  │              │                 │                   │
  │──────────────────▶│                  │              │                 │                   │
  │                   │                  │              │                 │                   │
  │                   │ StartTranscription│             │                 │                   │
  │                   │─────────────────▶│              │                 │                   │
  │                   │                  │  Write JSON  │                 │                   │
  │                   │                  │─────────────▶│                 │                   │
  │                   │                  │              │                 │                   │
  │                   │◀─ ─ ─ ─ ─ ─ ─ ─ │              │                 │                   │
  │                   │                  │              │                 │                   │
  │              ┌────┤ GetTranscriptionJob             │                 │                   │
  │              │    │─────────────────▶│              │                 │                   │
  │              │    │   IN_PROGRESS    │              │                 │                   │
  │              │    │◀─────────────────│              │                 │                   │
  │              │    │                  │              │                 │                   │
  │   (wait 30s)│    │ GetTranscriptionJob             │                 │                   │
  │              │    │─────────────────▶│              │                 │                   │
  │              │    │   COMPLETED      │              │                 │                   │
  │              └───▶│◀─────────────────│              │                 │                   │
  │                   │                  │              │                 │                   │
  │                   │  Invoke Lambda (ProcessTranscription)             │                   │
  │                   │─────────────────────────────────────────────────▶│                   │
  │                   │                  │              │                 │                   │
  │                   │                  │              │  GetObject      │                   │
  │                   │                  │              │◀────────────────│                   │
  │                   │                  │              │  (raw JSON)     │                   │
  │                   │                  │              │────────────────▶│                   │
  │                   │                  │              │                 │                   │
  │                   │                  │              │  PutObject      │                   │
  │                   │                  │              │◀────────────────│                   │
  │                   │                  │              │  (processed txt)│                   │
  │                   │                  │              │                 │                   │
  │                   │◀─────────────────────────────────────────────────│                   │
  │                   │   {processedTextKey}            │                 │                   │
  │                   │                  │              │                 │                   │
  │                   │  InvokeModel (Bedrock - Summarize)               │                   │
  │                   │────────────────────────────────────────────────────────────────────▶│
  │                   │                  │              │                 │                   │
  │                   │◀───────────────────────────────────────────────────────────────────│
  │                   │   {summary + action items}     │                 │                   │
  │                   │                  │              │                 │                   │
  │  Execution Done   │                  │              │                 │                   │
  │◀──────────────────│                  │              │                 │                   │
```

## Data Transformation Flow

```
┌──────────────────┐     ┌─────────────────────────────────┐     ┌───────────────────────┐
│   Audio File     │     │  Transcribe JSON Output          │     │  Processed Text       │
│   (.mp3/.wav)    │────▶│  {results: {transcripts: [...]}} │────▶│  (plain text .txt)    │
│   in S3          │     │  in S3                           │     │  in S3                │
└──────────────────┘     └─────────────────────────────────┘     └───────────┬───────────┘
                                                                              │
                                                                              ▼
                                                              ┌───────────────────────────┐
                                                              │  Summary + Action Items   │
                                                              │  (AI-generated text)      │
                                                              │  in S3                    │
                                                              └───────────────────────────┘
```

## State Machine States

| State | Type | Input | Output | Next |
|-------|------|-------|--------|------|
| StartTranscriptionJob | Task (Transcribe) | audioFileUri, jobName | transcription job metadata | CheckTranscriptionStatus |
| CheckTranscriptionStatus | Task (Transcribe) | jobName | job status | TranscriptionComplete? |
| TranscriptionComplete? | Choice | job status | — | ProcessTranscription or WaitForTranscription |
| WaitForTranscription | Wait (30s) | — | — | CheckTranscriptionStatus |
| ProcessTranscription | Task (Lambda) | jobName | processedTextKey | SummarizeWithBedrock |
| SummarizeWithBedrock | Task (Bedrock) | transcription text | summary + action items | END |
