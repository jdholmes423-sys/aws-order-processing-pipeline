# Create an SQS queue.
resource "aws_sqs_queue" "order_queue" {
    name = "order-processing-queue"
}

# Create a Dead-Letter queue
resource "aws_sqs_queue" "order_dlq" {
    name = "order-dlq-queue"
}

# Attach redrive policy to the main queue
resource "aws_sqs_queue_redrive_policy" "order_queue_rp" {
  queue_url = aws_sqs_queue.order_queue.id
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.order_dlq.arn
    maxReceiveCount     = 4
  })
}