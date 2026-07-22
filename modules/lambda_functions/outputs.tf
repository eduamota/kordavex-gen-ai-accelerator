output "process_transcription_function_arn" {
  value = aws_lambda_function.process_transcription.arn
}

output "summarize_text_function_arn" {
  value = aws_lambda_function.summarize_text.arn
}