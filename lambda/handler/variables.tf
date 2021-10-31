variable "environment" {
  default = "dev"
}

variable "s3_file_upload_bucket_arn" {}
variable "sns_images_topic_iam_policy_arn" {}
variable "sns_images_topic_arn" {}
