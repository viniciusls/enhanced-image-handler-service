module "policies" {
  source = "../policies"
}

resource "aws_api_gateway_integration" "item_put_method-api_proxy_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.item_resource.id
  http_method = aws_api_gateway_method.item_put_method.http_method

  type                    = "AWS"
  integration_http_method = "PUT"
  credentials             = module.policies.proxy_role_arn
  uri                     = "arn:aws:apigateway:${var.region}:s3:path/${var.s3_bucket_name}/{folder}/{item}"

  request_parameters = {
    "integration.request.header.x-amz-meta-fileinfo" = "method.request.header.x-amz-meta-fileinfo"
    "integration.request.header.Accept"              = "method.request.header.Accept"
    "integration.request.header.Content-Type"        = "method.request.header.Content-Type"

    "integration.request.path.item"   = "method.request.path.item"
    "integration.request.path.folder" = "method.request.path.folder"
  }
}

resource "aws_api_gateway_integration" "item_get_method-api_proxy_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.item_resource.id
  http_method = aws_api_gateway_method.item_get_method.http_method

  type                    = "AWS"
  integration_http_method = "GET"
  credentials             = module.policies.proxy_role_arn
  uri                     = "arn:aws:apigateway:${var.region}:s3:path/${var.s3_bucket_name}/{folder}/{item}"

  request_parameters = {
    "integration.request.path.item"   = "method.request.path.item"
    "integration.request.path.folder" = "method.request.path.folder"
  }
}

resource "aws_api_gateway_integration" "item_options_method-api_proxy_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.item_resource.id
  http_method = aws_api_gateway_method.item_options_method.http_method
  type        = "MOCK"
  depends_on  = [aws_api_gateway_method.item_options_method]

  request_templates = {
    "application/json" = <<EOF
        {
        "statusCode" : 200
        }
    EOF
  }
}
