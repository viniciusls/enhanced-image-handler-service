resource "aws_sns_topic" "topic" {
  name = var.topic_name
}

resource "aws_iam_policy" "iam_topic_policy" {
  name = "sns_iam_${var.topic_name}_policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sns:Publish"
        ]
        Effect   = "Allow"
        Resource = aws_sns_topic.topic.arn
      },
    ]
  })
}
