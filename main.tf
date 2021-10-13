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
}

module "s3" {
  source = "./s3"
}

module "analyzer_lambda" {
  source = "./analyzer"
}

module "handler_lambda" {
  source = "./handler"
}

module "thumbnailer_lambda" {
  source = "./thumbnailer"
}

module "s3-notifications" {
  source = "./s3-notifications"
}

module "policies" {
  source = "./policies"
}

module "api-gateway-s3-proxy" {
  source = "./api-gateway-s3-proxy"
}
