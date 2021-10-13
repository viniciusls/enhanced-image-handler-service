output "images_topic_arn" {
  value = aws_sns_topic.images_topic.arn
}

output "images_topic_iam_policy_arn" {
  value = aws_iam_policy.sns_iam_images_topic_policy.arn
}

output "results_topic_arn" {
  value = aws_sns_topic.results_topic.arn
}

output "results_topic_iam_policy_arn" {
  value = aws_iam_policy.sns_iam_results_topic_policy.arn
}
