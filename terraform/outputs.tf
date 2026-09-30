
# Display the API Gateway endpoint after deployment.
# This should make the deployed API easy to find and use. 
output "api_endpoint" {
    description = "Base URL for the order processing API"
    value = aws_apigatewayv2_api.orders_api.api_endpoint
}