resource "aws_sqs_queue" "analyzer_queue" {
  name                       = "${var.environment}-${var.sqs_queue_analyzer_name}"
  message_retention_seconds  = 86400
  visibility_timeout_seconds = 60
  receive_wait_time_seconds  = 20
}

resource "aws_sns_topic_subscription" "images_to_analyzer_subscription" {
  protocol             = "sqs"
  raw_message_delivery = true
  topic_arn            = var.sns_images_topic_arn
  endpoint             = aws_sqs_queue.analyzer_queue.arn
}

resource "aws_sqs_queue_policy" "sqs_analyzer_queue_policy" {
  queue_url = aws_sqs_queue.analyzer_queue.id

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
        Resource = aws_sqs_queue.analyzer_queue.arn
        Condition = {
          ArnEquals : {
            "aws:SourceArn" : var.sns_images_topic_arn
          }
        }
      },
    ]
  })
}

resource "aws_sqs_queue" "thumbnailer_queue" {
  name                       = "${var.environment}-${var.sqs_queue_thumbnailer_name}"
  message_retention_seconds  = 86400
  visibility_timeout_seconds = 60
  receive_wait_time_seconds  = 20
}

resource "aws_sns_topic_subscription" "images_to_thumbailer_subscription" {
  protocol             = "sqs"
  raw_message_delivery = true
  topic_arn            = var.sns_images_topic_arn
  endpoint             = aws_sqs_queue.thumbnailer_queue.arn
}

resource "aws_sqs_queue_policy" "sqs_thumbnailer_queue_policy" {
  queue_url = aws_sqs_queue.thumbnailer_queue.id

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
        Resource = aws_sqs_queue.thumbnailer_queue.arn
        Condition = {
          ArnEquals : {
            "aws:SourceArn" : var.sns_images_topic_arn
          }
        }
      },
    ]
  })
}
