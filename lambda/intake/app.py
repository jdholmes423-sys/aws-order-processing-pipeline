# Import the required modules
import json
import os

import boto3

# Give Python an SQS client
sqs = boto3.client("sqs")

# Allow Terraform to configure the Lambda environment variable.
QUEUE_URL = os.environ["QUEUE_URL"]


def lambda_handler(event, context):

    # Convert the API request JSON into a Python dictionary.
    body = json.loads(event["body"])

    # Place the order into the SQS queue. 
    response = sqs.send_message(
        QueueUrl=QUEUE_URL, 
        MessageBody=json.dumps(body)
    )

    # Create a confirmation output message. 
    return {
        "statusCode": 202,
        "body": json.dumps({
            "message": "Order accepted for processing.",
            "message_id": response["MessageId"]
        })
    }