data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = path.module
  output_path = "./analyzer/${var.environment}_analyzer_lambda.zip"
  excludes = [
    "${var.environment}_analyzer_lambda.zip",
    "main.tf",
    "outputs.tf",
    "variables.tf",
    "yarn.lock"
  ]
}

resource "aws_iam_role" "iam_for_analyzer_lambda" {
  name = "${var.environment}_iam_for_analyzer_lambda"

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
    var.sns_results_topic_iam_policy_arn,
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

resource "aws_lambda_function" "analyzer_lambda" {
  filename         = "./analyzer/${var.environment}_analyzer_lambda.zip"
  function_name    = "${var.environment}_analyzer_lambda"
  role             = aws_iam_role.iam_for_analyzer_lambda.arn
  handler          = "app.handler"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime          = "nodejs14.x"
  timeout          = 60
  memory_size      = 1024
  environment {
    variables = {
      ANALYZER_CLARIFAI_MODEL_ID = var.analyzer_clarifai_model_id
      CLARIFAI_API_KEY           = var.clarifai_api_key
      MONGODB_USER               = var.mongodb_user
      MONGODB_PASSWORD           = var.mongodb_password
      MONGODB_HOST               = var.mongodb_host
      MONGODB_DATABASE           = var.mongodb_database
    }
  }
}

resource "aws_lambda_event_source_mapping" "event_source_mapping" {
  event_source_arn = var.sqs_analyzer_queue_arn
  function_name    = aws_lambda_function.analyzer_lambda.arn
}
