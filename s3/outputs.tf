output "file_upload_bucket_arn" {
  value = aws_s3_bucket.file_upload_bucket.arn
}

output "file_upload_bucket_id" {
  value = aws_s3_bucket.file_upload_bucket.id
}

output "file_upload_policy_arn" {
  value = aws_iam_policy.file_upload_policy.arn
}

output "file_read_policy_arn" {
  value = aws_iam_policy.file_read_policy.arn
}
