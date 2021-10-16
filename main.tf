# Simple AWS Lambda Terraform Example
# requires 'index.js' in the same directory
# to test: run `terraform plan`
# to deploy: run `terraform apply`

terraform {
  backend "s3" {
    bucket = "viniciusls-terraform"
    key    = "enhanced-image-handler-service/terraform.tfstate"
    region = "sa-east-1"
  }
}

provider "aws" {
  region = var.region
}

module "sns" {
  source = "./sns"

  environment = var.environment
}

module "sqs" {
  source = "./sqs"

  sns_images_topic_arn = module.sns.images_topic_arn
  environment          = var.environment
}

module "s3" {
  source = "./s3"

  environment    = var.environment
  s3_bucket_name = var.s3_bucket_name
}

module "analyzer_lambda" {
  source = "./analyzer"

  environment                      = var.environment
  s3_file_read_policy_arn          = module.s3.file_read_policy_arn
  sns_results_topic_iam_policy_arn = module.sns.results_topic_iam_policy_arn
  sqs_analyzer_queue_arn           = module.sqs.analyzer_queue_arn
  analyzer_clarifai_model_id       = var.analyzer_clarifai_model_id
  clarifai_api_key                 = var.clarifai_api_key
  mongodb_user                     = var.mongodb_user
  mongodb_password                 = var.mongodb_password
  mongodb_host                     = var.mongodb_host
  mongodb_database                 = var.mongodb_database
}

module "handler_lambda" {
  source = "./handler"

  environment                     = var.environment
  s3_file_upload_bucket_arn       = module.s3.file_upload_bucket_arn
  sns_images_topic_iam_policy_arn = module.sns.images_topic_iam_policy_arn
  sns_images_topic_arn            = module.sns.images_topic_arn
}

module "thumbnailer_lambda" {
  source = "./thumbnailer"

  environment               = var.environment
  s3_file_read_policy_arn   = module.s3.file_read_policy_arn
  s3_file_upload_policy_arn = module.s3.file_upload_policy_arn
  sqs_thumbnailer_queue_arn = module.sqs.thumbnailer_queue_arn
}

module "s3-notifications" {
  source = "./s3-notifications"

  s3_file_upload_bucket_id = module.s3.file_upload_bucket_id
  lambda_handler_arn       = module.handler_lambda.lambda_arn
}

module "api-gateway-s3-proxy" {
  source = "./api-gateway-s3-proxy"

  s3_file_upload_policy_arn = module.s3.file_upload_policy_arn
  environment               = var.environment
}
