# Create the HTTP API. 
resource "aws_apigatewayv2_api" "orders_api" {
    name = "order-processing-api"
    protocol_type = "HTTP"
}
