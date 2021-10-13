resource "aws_sns_topic" "thumbnails" {
  name = var.sns_topic_images
}

resource "aws_iam_policy" "sns_iam_topic_policy" {
  name = "sns_iam_topic_policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sns:Publish"
        ]
        Effect = "Allow"
        Resource = aws_sns_topic.thumbnails.arn
      },
    ]
  })
}

