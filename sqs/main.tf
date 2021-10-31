resource "aws_sqs_queue" "queue" {
  name                       = var.sqs_queue_name
  message_retention_seconds  = 86400
  visibility_timeout_seconds = 60
  receive_wait_time_seconds  = 20
}

resource "aws_sns_topic_subscription" "sns_topic_subscription" {
  protocol             = "sqs"
  raw_message_delivery = true
  topic_arn            = var.sns_images_topic_arn
  endpoint             = aws_sqs_queue.queue.arn
}

resource "aws_sqs_queue_policy" "sqs_queue_policy" {
  queue_url = aws_sqs_queue.queue.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal : {
          Service : "sns.amazonaws.com"
        },
        Action = [
          "sqs:SendMessage"
        ]
        Resource = aws_sqs_queue.queue.arn
        Condition = {
          ArnEquals : {
            "aws:SourceArn" : var.sns_images_topic_arn
          }
        }
      },
    ]
  })
}
