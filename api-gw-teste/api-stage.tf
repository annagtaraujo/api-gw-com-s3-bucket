# resource "aws_api_gateway_deployment" "production" {
#   rest_api_id = aws_api_gateway_rest_api.opf_mtls_api_production.id

#   triggers = {
#     redeployment = sha1(replace(replace(jsonencode([
#       aws_api_gateway_rest_api.opf_mtls_api_production,
#       aws_api_gateway_method.opf_mtls_api_production,
#       aws_api_gateway_integration.opf_mtls_api_production,
#       aws_api_gateway_resource.proxy_all_paths,
#       aws_api_gateway_method.opf_mtls_api_production_all_paths,
#       aws_api_gateway_integration.opf_mtls_api_production_all_paths,
#       aws_api_gateway_method_response.sc200_all_paths,
#       aws_api_gateway_integration_response.opf_mtls_api_production_all_paths
#     ]), "\"", ""), ":", "="))
#   }
#   lifecycle {
#     create_before_destroy = true
#   }
# }

# resource "aws_api_gateway_stage" "production" {
#   deployment_id = aws_api_gateway_deployment.production.id
#   rest_api_id   = aws_api_gateway_rest_api.opf_mtls_api_production.id
#   stage_name    = "production"
#   depends_on    = [aws_api_gateway_deployment.production]

#   cache_cluster_enabled = false
#   cache_cluster_size    = "0.5"

#   access_log_settings {
#     destination_arn = var.kinesis_logs_mtls_api_arn

#     format = jsonencode(
#       {
#         "requestId" : "$context.requestId",
#         "ip" : "$context.identity.sourceIp",
#         "caller" : "$context.identity.caller",
#         "user" : "$context.identity.user",
#         "requestTime" : "$context.requestTime",
#         "httpMethod" : "$context.httpMethod",
#         "resourcePath" : "$context.resourcePath",
#         "status" : "$context.status",
#         "protocol" : "$context.protocol",
#         "responseLength" : "$context.responseLength"
#       }
#     )
#   }

#   lifecycle {
#     create_before_destroy = true
#   }
# }

# resource "aws_api_gateway_method_settings" "opf_mtls_api_production" {
#   rest_api_id = aws_api_gateway_rest_api.opf_mtls_api_production.id
#   stage_name  = aws_api_gateway_stage.production.stage_name
#   method_path = "*/*"

#   settings {
#     metrics_enabled    = true
#     data_trace_enabled = true
#     logging_level      = "INFO"
#     caching_enabled    = false

#     throttling_burst_limit = "5000"
#     throttling_rate_limit  = "1000"
#   }
#   depends_on = [aws_api_gateway_deployment.production]
# }
