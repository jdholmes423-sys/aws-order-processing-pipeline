# Allow API Gateway to invoke the intake Lambda.
resource "aws_lambda_permission" "api_gateway_to_intake" {
  statement_id  = "AllowAPIGatewayInvokeIntake"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.intake_lambda.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.orders_api.execution_arn}/*/*"
}
  
# Create the execution role for the intake Lambda. 
resource "aws_iam_role" "intake_lambda_role" {
    name = "intake_lambda_role"

    # Trust policy: allow Lambda to assume this role.
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Principal = {
                    Service = "lambda.amazonaws.com"
                }
                
                Action = "sts:AssumeRole"
            }
        ]
    })
}

# Give the intake Lambda permission to write logs
# and send messages to the order-processing queue. 
resource "aws_iam_policy" "intake_lambda_policy" {
  name        = "intake-lambda-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "*"
      },

      {
        Action = [
            "sqs:SendMessage"
        ]
        Effect = "Allow"
        Resource = aws_sqs_queue.order_queue.arn
      }
    ]
  })
}

# Attach the intake Lambda permissions to its execution role. 
resource "aws_iam_role_policy_attachment" "intake_lambda_policy_attachment" {
    role = aws_iam_role.intake_lambda_role.name
    policy_arn = aws_iam_policy.intake_lambda_policy.arn
}
