resource "aws_sns_topic" "images_topic" {
  name = var.sns_topic_images
}

resource "aws_sns_topic" "results_topic" {
  name = var.sns_topic_results
}
