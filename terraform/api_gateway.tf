# Create the HTTP API. 
resource "aws_apigatewayv2_api" "orders_api" {
    name = "order-processing-api"
    protocol_type = "HTTP"
}

# Connect API Gateway to the intake Lambda. 
resource "aws_apigatewayv2_integration" "intake_lambda_integration" {
  api_id           = aws_apigatewayv2_api.orders_api.id
  integration_type = "AWS_PROXY"
  description      = "intake lambda integration"
  integration_uri  = aws_lambda_function.intake_lambda.invoke_arn
}

# Route post requests for /orders to the intake Lambda. 
resource "aws_apigatewayv2_route" "example" {
  api_id    = aws_apigatewayv2_api.orders_api.id
  route_key = "POST /orders"
  target    = "integrations/${aws_apigatewayv2_integration.intake_lambda_integration.id}"
}

# Deploy the HTTP API using the default stage. 
resource "aws_apigatewayv2_stage" "api_stage" {
  api_id = aws_apigatewayv2_api.orders_api.id
  name   = "$$default"
  auto_deploy = true
}

# Allow the API Gateway to invoke the intake Lambda.
resource "aws_lambda_permission" "api_gateway_to_intake" {
  statement_id  = "AllowAPIGatewayInvokeIntake"
  action        = "lambda:InvokeFunction"
  function_name = aws_intake_lambda.intake_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_apigatewayv2_api.orders_api.execution_arn}/*/*"
}