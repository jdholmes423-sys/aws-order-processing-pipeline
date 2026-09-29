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


# Package the worker Python. 
data "archive_file" "worker_lambda_code" {
    type = "zip"
    source_file = "${path.module}/../lambda/worker/app.py"
    output_path = "${path.module}/../lambda/worker/worker_lambda.zip"
}

# Create the worker Lambda.
resource "aws_lambda_function" "worker_lambda" {
    function_name = "order-worker-lambda"
    
    role =  aws_iam_role.worker_lambda_role.arn
    runtime ="python3.12"
    handler = "app.lambda_handler"

    filename = data.archive_file.worker_lambda_code.output_path
    source_code_hash = data.archive_file.worker_lambda_code.output_base64sha256

    environment {
        variables = {
            TABLE_NAME = aws_dynamodb_table.orders.name
        }
    }
}

# Connect the SQS queue to the worker Lambda. 
resource "aws_lambda_event_source_mapping" "sqs_to_worker" {
  event_source_arn = aws_sqs_queue.order_queue.arn
  function_name    = aws_lambda_function.worker_lambda.arn
  batch_size       = 10
  enabled          = true
}