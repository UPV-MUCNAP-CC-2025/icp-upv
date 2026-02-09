import json
import boto3
import os

DDB_ENDPOINT = os.environ.get("DDB_ENDPOINT", "http://localstack:4566")  # dentro de docker-compose
AWS_REGION = os.environ.get("AWS_REGION", "eu-west-1")

dynamodb = boto3.resource(
    "dynamodb",
    endpoint_url=DDB_ENDPOINT,
    region_name=AWS_REGION,
    aws_access_key_id=os.environ.get("AWS_ACCESS_KEY_ID", "test"),
    aws_secret_access_key=os.environ.get("AWS_SECRET_ACCESS_KEY", "test"),
)

# dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table("todos")

def lambda_handler(event, context):
    print("EVENT:", json.dumps(event))
    route = get_route(event)
    try:
        #GET /todos
        if route == "GET /todos":
            response = table.scan()
            items = response.get("Items", [])
            return response_ok(items)
        # GET /todos/{id}
        elif route == "GET /todos/{id}":
            todo_id = event["pathParameters"]["id"]
            response = table.get_item(Key={"id": todo_id})
            if "Item" not in response:
                return response_error(404, "Todo no encontrado")
            return response_ok(response["Item"])
        # PUT /todos => crear y actualizar
        elif route == "PUT /todos":
            data = json.loads(event["body"])
            if not all(k in data for k in ("id", "todo", "status")):
                return response_error(400, "Faltan campos")
            table.put_item(
                Item={
                    "id": data["id"],
                    "todo": data["todo"],
                    "status": data["status"]
                }
            )
            return response_ok(f"Todo {data['id']} save")
        #DELETE /todos/{id}        
        elif route == "DELETE /todos/{id}":
            todo_id = event["pathParameters"]["id"]
            table.delete_item(Key={"id": todo_id})
            return response_ok(f"Todo {todo_id} deleted")
        #no existe ruta
        else:
            return response_error(400, f"No existe la ruta: {route}")
    except Exception as e:
        print("ERROR:", str(e))
        return response_error(500, str(e))
#Respuestas
def response_ok(body):
    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json",
            "access-control-allow-origin": "*",
            "access-control-allow-methods": "GET,PUT,DELETE,OPTIONS",
            "access-control-allow-headers": "*"
        },
        "body": json.dumps(body)
    }
def response_error(status, message):
    return {
        "statusCode": status,
        "headers": {
            "Content-Type": "application/json",
            "access-control-allow-origin": "*",
            "access-control-allow-methods": "GET,PUT,DELETE,OPTIONS",
            "access-control-allow-headers": "*"
        },
        "body": json.dumps({"error": message})
    }


def get_route(event):
    # HTTP API v2 (por si algún día lo cambias)
    if event.get("routeKey"):
        return event["routeKey"]

    # REST API v1
    method = event.get("httpMethod")
    resource = event.get("resource")  # aquí suele venir /todos o /todos/{id}
    if method and resource:
        return f"{method} {resource}"

    # fallback
    path = event.get("path")
    if method and path:
        return f"{method} {path}"

    return None