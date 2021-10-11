variable "s3_bucket_images" {
  default = "nodejs-aws-lambda-s3"
}

resource "aws_iam_role" "s3_proxy_role" {
  name               = "${var.environment}-s3-proxy-role-nodejs-lambda"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.s3_proxy_policy.json
}

data "aws_iam_policy_document" "s3_proxy_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "s3_proxy_role_file_upload_attachment" {
  depends_on = [
    aws_iam_policy.s3_file_upload_policy,
  ]

  role       = aws_iam_role.s3_proxy_role.name
  policy_arn = aws_iam_policy.s3_file_upload_policy.arn
}

resource "aws_iam_role_policy_attachment" "s3_proxy_role_api_gateway_attachment" {
  depends_on = [
    aws_iam_policy.s3_file_upload_policy,
  ]

  role       = aws_iam_role.s3_proxy_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonAPIGatewayInvokeFullAccess"
}

resource "aws_s3_bucket" "file_upload_bucket" {
  bucket = "${var.s3_bucket_images}-${var.environment}"
  acl    = "private"

  tags = {
    Name        = "${var.s3_bucket_images}-${var.environment}"
    Environment = var.environment
  }

  depends_on = [
    aws_iam_policy.s3_file_upload_policy,
  ]
}

resource "aws_iam_policy" "s3_file_upload_policy" {
  name        = "${var.environment}-nodejs-lambda-s3-file-upload-policy"
  path        = "/"
  description = "${var.environment} s3 file upload policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Effect = "Allow"
        Resource = "arn:aws:s3:::${var.s3_bucket_images}-${var.environment}/*"
      },
    ]
  })
}

resource "aws_s3_bucket_notification" "bucket_notification_png" {
  bucket = aws_s3_bucket.file_upload_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.aws_lambda_s3_thumbnail.arn
    events = [
      "s3:ObjectCreated:*"
    ]
    filter_prefix = "images/"
    filter_suffix = ".png"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.aws_lambda_s3_thumbnail.arn
    events = [
      "s3:ObjectCreated:*"
    ]
    filter_prefix = "images/"
    filter_suffix = ".jpg"
  }

  depends_on = [
    aws_lambda_permission.allow_bucket
  ]
}
