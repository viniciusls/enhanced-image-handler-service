output "file_upload_policy_arn" {
  value = aws_iam_policy.file_upload_policy.arn
}

output "file_read_policy_arn" {
  value = aws_iam_policy.file_read_policy.arn
}

output "proxy_role_arn" {
  value = aws_iam_role.proxy_role.arn
}
