data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = path.module
  output_path = "./thumbnailer/${var.environment}_thumbnailer_lambda.zip"
  excludes = [
    "${var.environment}_thumbnailer_lambda.zip",
    "main.tf",
    "outputs.tf",
    "variables.tf",
    "yarn.lock"
  ]
}

resource "aws_iam_role" "iam_for_thumbnailer_lambda" {
  name = "${var.environment}_iam_for_thumbnailer_lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole"
        ]
        Principal = {
          Service : "lambda.amazonaws.com"
        }
        Effect = "Allow"
      },
    ]
  })

  managed_policy_arns = [
    var.s3_file_read_policy_arn,
    var.s3_file_upload_policy_arn,
    data.aws_iam_policy.AWSLambdaBasicExecutionRole.arn,
    data.aws_iam_policy.AWSLambdaSQSQueueExecutionRole.arn,
  ]
}

data "aws_iam_policy" "AWSLambdaBasicExecutionRole" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy" "AWSLambdaSQSQueueExecutionRole" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole"
}

resource "aws_lambda_function" "thumbnailer_lambda" {
  filename         = "./thumbnailer/${var.environment}_thumbnailer_lambda.zip"
  function_name    = "${var.environment}_thumbnailer_lambda"
  role             = aws_iam_role.iam_for_thumbnailer_lambda.arn
  handler          = "app.handler"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime          = "nodejs14.x"
  timeout          = 60
  memory_size      = 1024
}

resource "aws_lambda_event_source_mapping" "event_source_mapping" {
  event_source_arn = var.sqs_thumbnailer_queue_arn
  function_name    = aws_lambda_function.thumbnailer_lambda.arn
}
