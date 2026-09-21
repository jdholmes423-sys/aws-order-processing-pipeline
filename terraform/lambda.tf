# Package the intake Python.
data "archive_file" "intake_lambda_code" {
    type = "zip"
    source_file = "${path.module}/../lambda/intake/app.py"
    output_path = "${path.module}/../lambda/intake/intake_lambda.zip"
}

# Create the intake Lambda.
resource "aws_lambda_function" "intake_lambda" {
    function_name = "order-intake-lambda"
    
    role =  aws_iam_role.intake_lambda_role.arn
    runtime ="python3.12"
    handler = "app.lambda_handler"

    filename = data.archive_file.intake_lambda_code.output_path
    source_code_hash = data.archive_file.intake_lambda_code.output_base64sha256

    environment {
        variables = {
            QUEUE_URL = aws_sqs_queue.order_queue.url
        }
    }
}

