resource "aws_api_gateway_resource" "bucket_resource" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  path_part   = "{bucket}"
}

resource "aws_api_gateway_resource" "folder_resource" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_resource.bucket_resource.id
  path_part   = "{folder}"
}

resource "aws_api_gateway_resource" "item_resource" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_resource.folder_resource.id
  path_part   = "{item}"
}
