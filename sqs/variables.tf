variable "environment" {
  default = "dev"
}

variable "sns_images_topic_arn" {}

variable "sqs_queue_analyzer_name" {
  default = "enhanced-image-handler-service-analyzer-queue"
}

variable "sqs_queue_thumbnailer_name" {
  default = "enhanced-image-handler-service-thumbnailer-queue"
}
