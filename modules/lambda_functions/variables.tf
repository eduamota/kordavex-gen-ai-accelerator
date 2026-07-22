variable "aws_region" {
  description = "The AWS region to create resources in"
  default     = "us-west-2"
}

variable "project_name" {
  description = "A project name to use as a prefix for resources"
  default     = "audio-processing"
}

variable "transcription_output_bucket" {
  description = "Name of the S3 bucket where transcriptions are stored"
}

variable "bedrock_model_id" {
  description = "Model ID for Amazon Bedrock"
  default     = "anthropic.claude-v2"
}