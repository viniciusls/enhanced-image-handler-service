resource "aws_sns_topic" "images_topic" {
  name = var.sns_topic_images
}

resource "aws_iam_policy" "sns_iam_images_topic_policy" {
  name = "sns_iam_images_topic_policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sns:Publish"
        ]
        Effect = "Allow"
        Resource = aws_sns_topic.images_topic.arn
      },
    ]
  })
}

resource "aws_sns_topic" "results_topic" {
  name = var.sns_topic_results
}

resource "aws_iam_policy" "sns_iam_results_topic_policy" {
  name = "sns_iam_results_topic_policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sns:Publish"
        ]
        Effect = "Allow"
        Resource = aws_sns_topic.results_topic.arn
      },
    ]
  })
}
