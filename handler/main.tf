data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = path.module
  output_path = "./handler/${var.environment}_handler_lambda.zip"
  excludes = [
    "${var.environment}_handler_lambda.zip",
    "main.tf",
    "outputs.tf",
    "variables.tf",
    "yarn.lock"
  ]
}

resource "aws_iam_role" "iam_for_handler_lambda" {
  name = "${var.environment}_iam_for_handler_lambda"

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
    var.sns_images_topic_iam_policy_arn,
    data.aws_iam_policy.AWSLambdaBasicExecutionRole.arn
  ]
}

data "aws_iam_policy" "AWSLambdaBasicExecutionRole" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.handler_lambda.arn
  principal     = "s3.amazonaws.com"
  source_arn    = var.s3_file_upload_bucket_arn
}

resource "aws_lambda_function" "handler_lambda" {
  filename         = "./handler/${var.environment}_handler_lambda.zip"
  function_name    = "${var.environment}_handler_lambda"
  role             = aws_iam_role.iam_for_handler_lambda.arn
  handler          = "app.handler"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime          = "nodejs14.x"
  timeout          = 60
  memory_size      = 1024
  environment {
    variables = {
      SNS_IMAGES_TOPIC_ARN = var.sns_images_topic_arn
    }
  }
}



