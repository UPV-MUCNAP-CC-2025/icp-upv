import json
import boto3
import os

dynamodb = boto3.resource(
    "dynamodb",
    endpoint_url="http://localhost:4566"
)

table = dynamodb.Table("hello-table")

def handler(event, context):
    # resp = table.scan()
    # items = resp.get("Items", [])

    items = ["hola", "Mundo"]

    return {
        "statusCode": 200,
        "headers": {
            "content-type": "application/json",
            "access-control-allow-origin": "*",
            "access-control-allow-methods": "GET,OPTIONS",
            "access-control-allow-headers": "*"
        },
        "body": json.dumps({
            "message": "Hello World from LocalStack 🚀",
            "items": items
        })
    }
