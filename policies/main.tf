resource "aws_iam_policy" "file_upload_policy" {
  name        = "lambda-s3-file-upload-policy"
  path        = "/"
  description = "s3 file upload policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:PutObject"
        ]
        Effect = "Allow"
        Resource = "arn:aws:s3:::${var.s3_bucket_name}/*"
      },
    ]
  })
}

resource "aws_iam_policy" "file_read_policy" {
  name        = "lambda-s3-file-upload-policy"
  path        = "/"
  description = "s3 file upload policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
        ]
        Effect = "Allow"
        Resource = "arn:aws:s3:::${var.s3_bucket_name}/*"
      },
    ]
  })
}

resource "aws_iam_role" "proxy_role" {
  name               = "s3-proxy-role-lambda"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.proxy_policy.json
}

data "aws_iam_policy_document" "proxy_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "proxy_role_file_upload_attachment" {
  depends_on = [
    aws_iam_policy.file_upload_policy,
  ]

  role       = aws_iam_role.proxy_role.name
  policy_arn = aws_iam_policy.file_upload_policy.arn
}

resource "aws_iam_role_policy_attachment" "proxy_role_api_gateway_attachment" {
  depends_on = [
    aws_iam_policy.file_upload_policy,
  ]

  role       = aws_iam_role.proxy_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonAPIGatewayInvokeFullAccess"
}
