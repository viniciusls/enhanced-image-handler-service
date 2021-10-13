module "s3" {
  source = "../s3"
}

resource "aws_api_gateway_rest_api" "api_gateway" {
  name               = "${var.environment}-s3-proxy-lambda"
  description        = "${var.environment} s3 proxy"
  binary_media_types = var.supported_binary_media_types
}

resource "aws_api_gateway_deployment" "s3_proxy_api_deployment" {
  depends_on = [
    aws_api_gateway_integration.item_put_method-api_proxy_integration,
    aws_api_gateway_integration.item_get_method-api_proxy_integration,
    aws_api_gateway_integration.item_options_method-api_proxy_integration
  ]

  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  stage_name = ""

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.api_gateway.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_usage_plan" "s3_proxy_usage_plan" {
  name        = "s3_proxy_usage_plan-lambda-${var.environment}"
  description = "usage plan for s3 proxy"

  api_stages {
    api_id = aws_api_gateway_rest_api.api_gateway.id
    stage  = aws_api_gateway_stage.api_stage.stage_name
  }
}

resource "aws_api_gateway_api_key" "s3_api_key" {
  name = "s3-proxy-lambda-apikey-${var.environment}"
}

resource "aws_api_gateway_usage_plan_key" "s3_proxy_usage_plan-key" {
  key_id        = aws_api_gateway_api_key.s3_api_key.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.s3_proxy_usage_plan.id
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
  role       = aws_iam_role.proxy_role.name
  policy_arn = module.s3.file_upload_policy_arn
}

resource "aws_iam_role_policy_attachment" "proxy_role_api_gateway_attachment" {
  role       = aws_iam_role.proxy_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonAPIGatewayInvokeFullAccess"
}
