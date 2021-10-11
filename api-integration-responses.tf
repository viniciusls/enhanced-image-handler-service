resource "aws_api_gateway_integration_response" "item_put_method-integration_response" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.item_resource.id
  http_method = aws_api_gateway_method.item_put_method.http_method

  status_code = aws_api_gateway_method_response.item_put_method_200_response.status_code

  response_templates = {
    "application/json" = ""
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }

  depends_on = [aws_api_gateway_method_response.item_put_method_200_response, aws_api_gateway_integration.item_put_method-api_proxy_integration]
}

resource "aws_api_gateway_integration_response" "item_get_method-integration_response" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.item_resource.id
  http_method = aws_api_gateway_method.item_get_method.http_method

  status_code = aws_api_gateway_method_response.item_get_method_200_response.status_code

  response_templates = {
    "application/json" = ""
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }

  depends_on = [aws_api_gateway_method_response.item_get_method_200_response, aws_api_gateway_integration.item_get_method-api_proxy_integration]
}

resource "aws_api_gateway_integration_response" "item_options_method-integration_response" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.item_resource.id
  http_method = aws_api_gateway_method.item_options_method.http_method
  status_code = aws_api_gateway_method_response.item_options_method_200_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,x-amz-meta-fileinfo'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,PUT,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  response_templates = {
    "application/json" = ""
  }

  depends_on = [aws_api_gateway_method_response.item_options_method_200_response, aws_api_gateway_integration.item_options_method-api_proxy_integration]
}
