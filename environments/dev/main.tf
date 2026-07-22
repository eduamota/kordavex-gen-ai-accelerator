provider "aws" {
  region = "us-west-2"  # or your preferred region
}

module "audio_processing_workflow" {
  source = "./modules/audio_processing_workflow"

  aws_region           = "us-west-2"
  step_functions_name  = "MyAudioProcessingWorkflow"
  lambda_function_arn  = "arn:aws:lambda:us-west-2:123456789012:function:MyTranscriptionProcessor"
  output_bucket_name   = "my-transcription-output-bucket"
  
  # Optional: override defaults
  # transcribe_language_code = "es-ES"
  # bedrock_model_id = "anthropic.claude-v1"
}

output "state_machine_arn" {
  value = module.audio_processing_workflow.state_machine_arn
}

module "lambda_functions" {
  source = "./modules/lambda_functions"

  aws_region                 = "us-west-2"
  project_name               = "my-audio-processing"
  transcription_output_bucket = "my-transcription-output-bucket"
  bedrock_model_id           = "anthropic.claude-v2"
}

output "process_transcription_function_arn" {
  value = module.lambda_functions.process_transcription_function_arn
}

output "summarize_text_function_arn" {
  value = module.lambda_functions.summarize_text_function_arn
}