resource "aws_api_gateway_stage" "dev" {
  deployment_id = aws_api_gateway_deployment.s3_proxy_api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  stage_name    = "dev"
}

resource "aws_api_gateway_method_settings" "dev_all" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  stage_name  = aws_api_gateway_stage.dev.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled = true
    logging_level   = "ERROR"
  }
}
