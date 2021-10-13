module "handler_lambda" {
  source = "../handler"
}

module "s3" {
  source = "../s3"
}

resource "aws_s3_bucket_notification" "bucket_notification_png" {
  bucket = module.s3.file_upload_bucket_id

  lambda_function {
    lambda_function_arn = module.handler_lambda.lambda_arn
    events = [
      "s3:ObjectCreated:*"
    ]
    filter_prefix = "images/"
    filter_suffix = ".png"
  }

  lambda_function {
    lambda_function_arn = module.handler_lambda.lambda_arn
    events = [
      "s3:ObjectCreated:*"
    ]
    filter_prefix = "images/"
    filter_suffix = ".jpg"
  }
}
