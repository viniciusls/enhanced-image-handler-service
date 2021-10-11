variable "ses_subscription_email" {
  default = ""
  type = string
}

resource "aws_sns_topic" "thumbnails" {
  name = "thumbnails-topic"
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

resource "aws_sns_topic_subscription" "thumbnails_ses_target" {
  topic_arn = aws_sns_topic.thumbnails.arn
  protocol  = "email"
  endpoint  = var.ses_subscription_email // TF_VAR_ses_subscription_arn
}
