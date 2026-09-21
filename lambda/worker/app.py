import json
import os

import boto3

dynamodb = boto3.resource("dynamodb")

TABLE_NAME = os.environ["TABLE_NAME"]

table = dynamodb.Table(TABLE_NAME)


def lambda_handler(event, context):
    records = event.get("Records", [])

    print(f"Received {len(records)} SQS record(s).")

    for record in records:
        message_body = record["body"]

        order = json.loads(message_body)

        print(f"Processing order: {order}")

        table.put_item(Item=order)

        print("Order stored in DynamoDB.")


    return {
        "statusCode": 200, 
        "body": json.dumps({
            "message": "Orders processed successfully.",
            "records_processed": len(records)
            })
        }



