module "s3" {
  source = "../s3"
}

data "archive_file" "lambda_zip" {
  type = "zip"
  source_dir = path.module
  output_path = "thumbnailer_lambda.zip"
  excludes = [
    "thumbnailer_lambda.zip",
    "main.tf",
    "outputs.tf",
    "variables.tf",
    "yarn.lock"
  ]
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole"
        ]
        Principal = {
          Service: "lambda.amazonaws.com"
        }
        Effect = "Allow"
      },
    ]
  })

  managed_policy_arns = [
    module.s3.file_read_policy_arn,
    module.s3.file_upload_policy_arn,
    data.aws_iam_policy.AWSLambdaBasicExecutionRole.arn,
  ]
}

data "aws_iam_policy" "AWSLambdaBasicExecutionRole" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "thumbnailer_lambda" {
  filename = "thumbnailer_lambda.zip"
  function_name = "thumbnailer_lambda"
  role = aws_iam_role.iam_for_lambda.arn
  handler = "app.handler"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime = "nodejs14.x"
  timeout = 60
  memory_size = 1024
}
