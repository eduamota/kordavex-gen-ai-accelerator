variable "aws_region" {
  description = "The AWS region to create resources in"
  default     = "us-west-2"
}

variable "step_functions_name" {
  description = "Name of the Step Functions state machine"
  default     = "AudioProcessingWorkflow"
}

variable "transcribe_language_code" {
  description = "Language code for Amazon Transcribe"
  default     = "en-US"
}

variable "bedrock_model_id" {
  description = "Model ID for Amazon Bedrock"
  default     = "anthropic.claude-v2"
}

variable "lambda_function_arn" {
  description = "ARN of the Lambda function to process transcription"
}

variable "output_bucket_name" {
  description = "Name of the S3 bucket to store transcription output"
}