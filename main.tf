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

module "sns_images_topic" {
  source = "./sns"

  topic_name  = "${var.environment}-${var.sns_topic_images_name}"
  environment = var.environment
}

module "sns_results_topic" {
  source = "./sns"

  topic_name  = "${var.environment}-${var.sns_topic_results_name}"
  environment = var.environment
}

module "sqs_analyzer_queue" {
  source = "./sqs"

  sns_images_topic_arn = module.sns_images_topic.topic_arn
  sqs_queue_name       = "${var.environment}-${var.sqs_queue_analyzer_name}"
  environment          = var.environment
}

module "sqs_thumbnailer_queue" {
  source = "./sqs"

  sns_images_topic_arn = module.sns_images_topic.topic_arn
  sqs_queue_name       = "${var.environment}-${var.sqs_queue_thumbnailer_name}"
  environment          = var.environment
}

module "s3" {
  source = "./s3"

  environment    = var.environment
  s3_bucket_name = var.s3_bucket_name
}

module "ec2_mongo_redis" {
  source = "./ec2-mongo-redis"

  ami_id   = var.ami_id
  key_name = var.ec2_key_name
  vpc_id   = var.vpc_id
}

module "analyzer_lambda" {
  source = "./analyzer"

  environment                         = var.environment
  s3_file_read_policy_arn             = module.s3.file_read_policy_arn
  sns_results_topic_iam_policy_arn    = module.sns_results_topic.topic_iam_policy_arn
  sqs_analyzer_queue_arn              = module.sqs_analyzer_queue.queue_arn
  analyzer_clarifai_model_id          = var.analyzer_clarifai_model_id
  clarifai_api_key                    = var.clarifai_api_key
  mongodb_user                        = var.mongodb_user
  mongodb_password                    = var.mongodb_password
  mongodb_host                        = module.ec2_mongo_redis.address
  mongodb_personal_host               = var.mongodb_personal_host
  mongodb_database                    = var.mongodb_database
  mongodb_analysis_results_collection = var.mongodb_analysis_results_collection
}

module "handler_lambda" {
  source = "./handler"

  environment                     = var.environment
  s3_file_upload_bucket_arn       = module.s3.file_upload_bucket_arn
  sns_images_topic_arn            = module.sns_images_topic.topic_arn
  sns_images_topic_iam_policy_arn = module.sns_images_topic.topic_iam_policy_arn
}

module "retriever_lambda" {
  source = "./retriever"

  environment                         = var.environment
  s3_bucket_name                      = var.s3_bucket_name
  mongodb_user                        = var.mongodb_user
  mongodb_password                    = var.mongodb_password
  mongodb_host                        = module.ec2_mongo_redis.address
  mongodb_personal_host               = var.mongodb_personal_host
  mongodb_database                    = var.mongodb_database
  mongodb_analysis_results_collection = var.mongodb_analysis_results_collection
  redis_host                          = module.ec2_mongo_redis.address
  redis_personal_host                 = var.redis_personal_host
  redis_port                          = "6379"
  redis_user                          = var.redis_user
  redis_password                      = var.redis_password
}

module "thumbnailer_lambda" {
  source = "./thumbnailer"

  environment               = var.environment
  s3_file_read_policy_arn   = module.s3.file_read_policy_arn
  s3_file_upload_policy_arn = module.s3.file_upload_policy_arn
  sqs_thumbnailer_queue_arn = module.sqs_thumbnailer_queue.queue_arn
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

module "api-gateway-retriever-proxy" {
  source = "./api-gateway-retriever-proxy"

  lambda_retriever_arn = module.retriever_lambda.lambda_arn
  environment          = var.environment
}
