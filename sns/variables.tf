variable "environment" {
  default = "dev"
}

variable "sns_topic_images_name" {
  default = "enhanced-image-handler-service-images-topic"
}

variable "sns_topic_results_name" {
  default = "enhanced-image-handler-service-results-topic"
}
