resource "aws_sns_topic" "images_topic" {
  name = "${var.environment}-${var.sns_topic_images_name}"
}

resource "aws_iam_policy" "sns_iam_images_topic_policy" {
  name = "${var.environment}_sns_iam_images_topic_policy"

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
  name = "${var.environment}-${var.sns_topic_results_name}"
}

resource "aws_iam_policy" "sns_iam_results_topic_policy" {
  name = "${var.environment}_sns_iam_results_topic_policy"

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
