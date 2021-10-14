variable "s3_file_upload_bucket_id" {}
variable "lambda_handler_arn" {}

resource "aws_s3_bucket_notification" "bucket_notification_png" {
  bucket = var.s3_file_upload_bucket_id

  lambda_function {
    lambda_function_arn = var.lambda_handler_arn
    events = [
      "s3:ObjectCreated:*"
    ]
    filter_prefix = "images/"
    filter_suffix = ".png"
  }

  lambda_function {
    lambda_function_arn = var.lambda_handler_arn
    events = [
      "s3:ObjectCreated:*"
    ]
    filter_prefix = "images/"
    filter_suffix = ".jpg"
  }
}
