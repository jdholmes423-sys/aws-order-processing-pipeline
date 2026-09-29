# Create the DynamoDB table for processed orders. 
resource "aws_dynamodb_table" "orders" {
  name           = "Orders"
  billing_mode   = "PAY_PER_REQUEST"
  
  # Use order_id as the partition key. 
  hash_key       = "order_id"

  # Define the partition key as a string. 
  attribute {
    name = "order_id"
    type = "S"
  }
}