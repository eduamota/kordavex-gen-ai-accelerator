resource "aws_iam_role" "lambda_role" {
  name = "${var.project_name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_role.name
}

resource "aws_iam_role_policy" "lambda_s3_access" {
  name = "${var.project_name}-lambda-s3-access"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = "arn:aws:s3:::${var.transcription_output_bucket}/*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_bedrock_access" {
  name = "${var.project_name}-lambda-bedrock-access"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "bedrock:InvokeModel"
        ]
        Resource = "*"
      }
    ]
  })
}

data "archive_file" "process_transcription_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_functions/process_transcription.py"
  output_path = "${path.module}/lambda_functions/process_transcription.zip"
}

resource "aws_lambda_function" "process_transcription" {
  filename         = data.archive_file.process_transcription_zip.output_path
  function_name    = "${var.project_name}-process-transcription"
  role             = aws_iam_role.lambda_role.arn
  handler          = "process_transcription.lambda_handler"
  source_code_hash = data.archive_file.process_transcription_zip.output_base64sha256
  runtime          = "python3.9"

  environment {
    variables = {
      OUTPUT_BUCKET = var.transcription_output_bucket
    }
  }
}

data "archive_file" "summarize_text_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_functions/summarize_text.py"
  output_path = "${path.module}/lambda_functions/summarize_text.zip"
}

resource "aws_lambda_function" "summarize_text" {
  filename         = data.archive_file.summarize_text_zip.output_path
  function_name    = "${var.project_name}-summarize-text"
  role             = aws_iam_role.lambda_role.arn
  handler          = "summarize_text.lambda_handler"
  source_code_hash = data.archive_file.summarize_text_zip.output_base64sha256
  runtime          = "python3.9"

  environment {
    variables = {
      BEDROCK_MODEL_ID = var.bedrock_model_id
    }
  }
}