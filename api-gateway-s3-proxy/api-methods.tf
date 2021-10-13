resource "aws_api_gateway_method" "item_put_method" {
  rest_api_id      = aws_api_gateway_rest_api.api_gateway.id
  resource_id      = aws_api_gateway_resource.item_resource.id
  http_method      = "PUT"
  authorization    = "NONE"
  api_key_required = true

  request_parameters = {
    "method.request.header.Accept"              = false
    "method.request.header.Content-Type"        = false
    "method.request.header.x-amz-meta-fileinfo" = false

    "method.request.path.bucket" = true
    "method.request.path.folder" = true
    "method.request.path.item"   = true
  }
}

resource "aws_api_gateway_method" "item_options_method" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.item_resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"

  request_parameters = {
    "method.request.header.x-amz-meta-fileinfo" = false
  }
}

resource "aws_api_gateway_method" "item_get_method" {
  rest_api_id      = aws_api_gateway_rest_api.api_gateway.id
  resource_id      = aws_api_gateway_resource.item_resource.id
  http_method      = "GET"
  authorization    = "NONE"
  api_key_required = true

  request_parameters = {
    "method.request.path.bucket" = true
    "method.request.path.folder" = true
    "method.request.path.item"   = true
  }
}
