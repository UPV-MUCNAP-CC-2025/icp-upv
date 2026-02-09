import json
import boto3

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table("todos")

def lambda_handler(event, context):
    print("EVENT:", json.dumps(event))
    route = event.get("routeKey")
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
            "access-control-allow-methods": "GET,OPTIONS",
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
            "access-control-allow-methods": "GET,OPTIONS",
            "access-control-allow-headers": "*"
        },
        "body": json.dumps({"error": message})
    }
