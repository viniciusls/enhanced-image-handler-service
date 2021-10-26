data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = path.module
  output_path = "./retriever/${var.environment}_retriever_lambda.zip"
  excludes = [
    "${var.environment}_retriever_lambda.zip",
    "main.tf",
    "outputs.tf",
    "variables.tf",
    "yarn.lock"
  ]
}

resource "aws_iam_role" "iam_for_retriever_lambda" {
  name = "${var.environment}_iam_for_retriever_lambda"

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
    data.aws_iam_policy.AWSLambdaBasicExecutionRole.arn
  ]
}

data "aws_iam_policy" "AWSLambdaBasicExecutionRole" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "retriever_lambda" {
  filename         = "./retriever/${var.environment}_retriever_lambda.zip"
  function_name    = "${var.environment}_retriever_lambda"
  role             = aws_iam_role.iam_for_retriever_lambda.arn
  handler          = "app.handler"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime          = "nodejs14.x"
  timeout          = 60
  memory_size      = 1024
  environment {
    variables = {
      ENVIRONMENT                         = var.environment
      MONGODB_USER                        = var.mongodb_user
      MONGODB_PASSWORD                    = var.mongodb_password
      MONGODB_HOST                        = var.mongodb_host
      MONGODB_DATABASE                    = var.mongodb_database
      MONGODB_ANALYSIS_RESULTS_COLLECTION = var.mongodb_analysis_results_collection
      S3_BUCKET_NAME                      = "${var.environment}-${var.s3_bucket_name}"
      REDIS_ADDRESS                       = var.redis_host
      REDIS_PORT                          = var.redis_port
      REDIS_USER                          = var.redis_user
      REDIS_PASSWORD                      = var.redis_password
    }
  }
}
