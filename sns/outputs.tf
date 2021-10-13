output "images_topic_arn" {
  value = aws_sns_topic.images_topic.arn
}

output "results_topic_arn" {
  value = aws_sns_topic.results_topic.arn
}
