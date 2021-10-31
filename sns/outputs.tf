output "topic_arn" {
  value = aws_sns_topic.topic.arn
}

output "topic_iam_policy_arn" {
  value = aws_iam_policy.iam_topic_policy.arn
}
