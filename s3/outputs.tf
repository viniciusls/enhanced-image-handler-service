output "file_upload_bucket_arn" {
  value = aws_s3_bucket.file_upload_bucket.arn
}

output "file_upload_bucket_id" {
  value = aws_s3_bucket.file_upload_bucket.id
}
