resource "aws_iam_role" "step_functions_role" {
  name = "${var.step_functions_name}_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "states.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "step_functions_policy" {
  name = "${var.step_functions_name}_policy"
  role = aws_iam_role.step_functions_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "transcribe:StartTranscriptionJob",
          "transcribe:GetTranscriptionJob",
          "s3:GetObject",
          "s3:PutObject",
          "lambda:InvokeFunction",
          "bedrock:InvokeModel"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_sfn_state_machine" "audio_processing_workflow" {
  name     = var.step_functions_name
  role_arn = aws_iam_role.step_functions_role.arn

  definition = jsonencode({
    Comment = "Audio Processing Workflow"
    StartAt = "StartTranscriptionJob"
    States = {
      StartTranscriptionJob = {
        Type = "Task"
        Resource = "arn:aws:states:::transcribe:startTranscriptionJob"
        Parameters = {
          LanguageCode = var.transcribe_language_code
          Media = {
            MediaFileUri = "$.audioFileUri"
          }
          TranscriptionJobName = "$.jobName"
          OutputBucketName = var.output_bucket_name
        }
        Next = "CheckTranscriptionStatus"
      }
      CheckTranscriptionStatus = {
        Type = "Task"
        Resource = "arn:aws:states:::transcribe:getTranscriptionJob"
        Parameters = {
          TranscriptionJobName = "$.jobName"
        }
        Next = "TranscriptionComplete?"
      }
      "TranscriptionComplete?" = {
        Type = "Choice"
        Choices = [
          {
            Variable = "$.TranscriptionJob.TranscriptionJobStatus"
            StringEquals = "COMPLETED"
            Next = "ProcessTranscription"
          }
        ]
        Default = "WaitForTranscription"
      }
      WaitForTranscription = {
        Type = "Wait"
        Seconds = 30
        Next = "CheckTranscriptionStatus"
      }
      ProcessTranscription = {
        Type = "Task"
        Resource = "arn:aws:states:::lambda:invoke"
        Parameters = {
          FunctionName = var.lambda_function_arn
          Payload = {
            transcriptionJobName = "$.jobName"
          }
        }
        Next = "SummarizeWithBedrock"
      }
      SummarizeWithBedrock = {
        Type = "Task"
        Resource = "arn:aws:states:::bedrock:invokeModel"
        Parameters = {
          ModelId = var.bedrock_model_id
          Body = {
            prompt = "Summarize the following text and extract action items: $.transcription"
          }
        }
        End = true
      }
    }
  })
}