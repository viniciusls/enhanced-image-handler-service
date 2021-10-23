resource "aws_apigatewayv2_api" "lambda" {
  name          = "enhanced-image-handler-service-retriever-lambda-proxy"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "lambda" {
  api_id = aws_apigatewayv2_api.lambda.id

  name        = var.environment
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw_retriever.arn

    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
      }
    )
  }
}

resource "aws_apigatewayv2_integration" "find_by_terms" {
  api_id = aws_apigatewayv2_api.lambda.id

  integration_uri    = var.lambda_retriever_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "find_by_terms" {
  api_id = aws_apigatewayv2_api.lambda.id

  route_key = "POST /analysis/terms"
  target    = "integrations/${aws_apigatewayv2_integration.find_by_terms.id}"
}

resource "aws_cloudwatch_log_group" "api_gw_retriever" {
  name = "/aws/${var.environment}_api_gw_retriever/${aws_apigatewayv2_api.lambda.name}"

  retention_in_days = 30
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_retriever_arn
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.lambda.execution_arn}/*/*"
}
