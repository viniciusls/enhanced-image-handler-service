output "analyzer_queue_arn" {
  value = aws_sqs_queue.analyzer_queue.arn
}

output "thumbnailer_queue_arn" {
  value = aws_sqs_queue.thumbnailer_queue.arn
}
