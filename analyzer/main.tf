module "s3" {
  source = "../s3"
}

module "sns" {
  source = "../sns"
}

module "sqs" {
  source = "../sqs"
}

data "archive_file" "lambda_zip" {
  type = "zip"
  source_dir = path.module
  output_path = "./analyzer/analyzer_lambda.zip"
  excludes = [
    "analyzer_lambda.zip",
    "main.tf",
    "outputs.tf",
    "variables.tf",
    "yarn.lock"
  ]
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_analyzer_lambda"

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
    module.sns.results_topic_iam_policy_arn,
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
  filename = "./analyzer/analyzer_lambda.zip"
  function_name = "analyzer_lambda"
  role = aws_iam_role.iam_for_lambda.arn
  handler = "app.handler"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime = "nodejs14.x"
  timeout = 60
  memory_size = 1024
}

resource "aws_lambda_event_source_mapping" "event_source_mapping" {
  event_source_arn = module.sqs.analyzer_queue_arn
  function_name    = aws_lambda_function.analyzer_lambda.arn
}
