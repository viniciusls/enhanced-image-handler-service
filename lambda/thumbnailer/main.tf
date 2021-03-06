data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = path.module
  output_path = "./lambda/thumbnailer/${var.environment}_thumbnailer_lambda.zip"
  excludes = [
    "${var.environment}_thumbnailer_lambda.zip",
    "main.tf",
    "outputs.tf",
    "variables.tf"
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

module "thumbnailer_lambda" {
  source = "../"

  filename         = "./lambda/thumbnailer/${var.environment}_thumbnailer_lambda.zip"
  function_name    = "${var.environment}_thumbnailer_lambda"
  iam_role_arn     = aws_iam_role.iam_for_thumbnailer_lambda.arn
  handler          = "app.handler"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime          = "python3.8"
  timeout          = 3
  memory_size      = 128
  layers           = ["arn:aws:lambda:sa-east-1:770693421928:layer:Klayers-python38-Pillow:14"]
}

resource "aws_lambda_event_source_mapping" "event_source_mapping" {
  event_source_arn = var.sqs_thumbnailer_queue_arn
  function_name    = module.thumbnailer_lambda.lambda_arn
}
