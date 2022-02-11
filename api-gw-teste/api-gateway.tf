resource "aws_api_gateway_rest_api" "api_teste" {
  name = "API-TESTE-ANNA"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
  
  binary_media_types = [
    "image/jpeg"
    ]

  disable_execute_api_endpoint = true
}

#---------------------------------------------------------------------------
# bucket
#---------------------------------------------------------------------------

# resource "aws_api_gateway_resource" "bucket" {
#   rest_api_id = aws_api_gateway_rest_api.api_teste.id
#   parent_id   = aws_api_gateway_rest_api.api_teste.root_resource_id
#   path_part   = "bucket"
# }

#---------------------------------------------------------------------------
# {item}
#---------------------------------------------------------------------------
resource "aws_api_gateway_resource" "item" {
  rest_api_id = aws_api_gateway_rest_api.api_teste.id
  parent_id   = aws_api_gateway_rest_api.api_teste.root_resource_id #aws_api_gateway_resource.bucket.id
  path_part   = "{item}"
}

resource "aws_api_gateway_method" "add_item" {
  rest_api_id      = aws_api_gateway_rest_api.api_teste.id
  resource_id      = aws_api_gateway_resource.item.id
  http_method      = "POST"
  authorization    = "NONE"
  api_key_required = false

  request_parameters = {
    "method.request.path.item" = true
    "method.request.header.Content-Type" = true
  }
  
}

resource "aws_api_gateway_integration" "s3_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_teste.id
  resource_id = aws_api_gateway_resource.item.id
  http_method = aws_api_gateway_method.add_item.http_method

  integration_http_method = "PUT"
 # See uri description: https://docs.aws.amazon.com/apigateway/api-reference/resource/integration/
  type = "AWS"
  uri  = format("arn:aws:apigateway:us-east-1:s3:path/%s/{item}",module.bucket_api_teste.this_s3_bucket_id) 
  credentials = aws_iam_role.cloudwatch_s3.arn
  
  request_parameters = {
    "integration.request.path.item" = "method.request.path.item"
  }
  passthrough_behavior = "WHEN_NO_MATCH"
  content_handling = "CONVERT_TO_BINARY"
  
  depends_on = [
    module.bucket_api_teste
  ]
}

resource "aws_api_gateway_method_response" "add_200" {
  rest_api_id = aws_api_gateway_rest_api.api_teste.id
  resource_id = aws_api_gateway_resource.item.id
  http_method = aws_api_gateway_method.add_item.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"#"mensagem: Envio com sucesso"
  }

  depends_on = [aws_api_gateway_integration.s3_integration]
}

resource "aws_api_gateway_integration_response" "add_response" {
  rest_api_id = aws_api_gateway_rest_api.api_teste.id
  resource_id = aws_api_gateway_resource.item.id
  http_method = aws_api_gateway_method.add_item.http_method
  status_code = aws_api_gateway_method_response.add_200.status_code

  depends_on = [aws_api_gateway_integration.s3_integration]
}
