variable "environment" {
  default = "dev"
}

variable "s3_file_read_policy_arn" {}
variable "s3_file_upload_policy_arn" {}
variable "sqs_thumbnailer_queue_arn" {}
