#!/bin/bash
set -e

echo "⏳ Esperando a LocalStack..."
sleep 5

echo "📦 Creando bucket S3"
awslocal s3 mb s3://hello-bucket

echo "🗄️ Creando tabla DynamoDB"
awslocal dynamodb create-table \
  --table-name todos \
  --attribute-definitions AttributeName=id,AttributeType=S \
  --key-schema AttributeName=id,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST

echo "🧠 Creando Lambda"
cd /backend
zip -r /lambda/todo.zip lambda_function.py

awslocal lambda create-function \
  --function-name todo-lambda \
  --runtime python3.12 \
  --handler lambda_function.lambda_handler \
  --role arn:aws:iam::000000000000:role/lambda-role \
  --zip-file fileb:///lambda/todo.zip

echo "🌍 Creando API Gateway"
API_ID=$(awslocal apigateway create-rest-api --name todo-api --query 'id' --output text)

ROOT_ID=$(awslocal apigateway get-resources \
  --rest-api-id $API_ID \
  --query 'items[0].id' \
  --output text)

RESOURCE_ID=$(awslocal apigateway create-resource \
  --rest-api-id $API_ID \
  --parent-id $ROOT_ID \
  --path-part todos \
  --query 'id' \
  --output text)

awslocal apigateway put-method \
  --rest-api-id $API_ID \
  --resource-id $RESOURCE_ID \
  --http-method GET \
  --authorization-type NONE

awslocal apigateway put-integration \
  --rest-api-id $API_ID \
  --resource-id $RESOURCE_ID \
  --http-method GET \
  --type AWS_PROXY \
  --integration-http-method POST \
  --uri arn:aws:apigateway:eu-west-1:lambda:path/2015-03-31/functions/arn:aws:lambda:eu-west-1:000000000000:function:todo-lambda/invocations

awslocal apigateway put-method \
  --rest-api-id $API_ID \
  --resource-id $RESOURCE_ID \
  --http-method PUT \
  --authorization-type NONE 

awslocal apigateway put-integration \
  --rest-api-id $API_ID \
  --resource-id $RESOURCE_ID \
  --http-method PUT \
  --type AWS_PROXY \
  --integration-http-method POST \
  --uri arn:aws:apigateway:eu-west-1:lambda:path/2015-03-31/functions/arn:aws:lambda:eu-west-1:000000000000:function:todo-lambda/invocations


# --- Crear subrecurso /todos/{id} ---
TODO_ID_RES_ID=$(awslocal apigateway create-resource \
  --rest-api-id $API_ID \
  --parent-id $RESOURCE_ID \
  --path-part "{id}" \
  --query 'id' \
  --output text)

# --- GET /todos/{id} ---
awslocal apigateway put-method \
  --rest-api-id $API_ID \
  --resource-id $TODO_ID_RES_ID \
  --http-method GET \
  --authorization-type NONE

awslocal apigateway put-integration \
  --rest-api-id $API_ID \
  --resource-id $TODO_ID_RES_ID \
  --http-method GET \
  --type AWS_PROXY \
  --integration-http-method POST \
  --uri arn:aws:apigateway:eu-west-1:lambda:path/2015-03-31/functions/arn:aws:lambda:eu-west-1:000000000000:function:todo-lambda/invocations

# --- DELETE /todos/{id} ---
awslocal apigateway put-method \
  --rest-api-id $API_ID \
  --resource-id $TODO_ID_RES_ID \
  --http-method DELETE \
  --authorization-type NONE

awslocal apigateway put-integration \
  --rest-api-id $API_ID \
  --resource-id $TODO_ID_RES_ID \
  --http-method DELETE \
  --type AWS_PROXY \
  --integration-http-method POST \
  --uri arn:aws:apigateway:eu-west-1:lambda:path/2015-03-31/functions/arn:aws:lambda:eu-west-1:000000000000:function:todo-lambda/invocations


awslocal apigateway create-model \
  --rest-api-id $API_ID \
  --name TodoModel \
  --content-type application/json \
  --schema '{
    "$schema": "http://json-schema.org/draft-04/schema#",
    "type": "object",
    "required": ["id","todo","status"],
    "properties": {
      "id": { "type": "string" },
      "todo": { "type": "string" },
      "status": { "type": "string" }
    }
  }'

  awslocal apigateway update-method \
  --rest-api-id $API_ID \
  --resource-id $RESOURCE_ID \
  --http-method PUT \
  --patch-operations op=replace,path=/requestModels/application~1json,value=TodoModel

awslocal apigateway create-deployment \
  --rest-api-id $API_ID \
  --stage-name dev

echo ""
echo "✅ API lista:"
echo "👉 http://localhost:4566/restapis/$API_ID/dev/_user_request_"

echo "🧾 Exportando y parcheando swagger para Swagger UI..."

# 1) Export raw swagger desde apigateway
awslocal apigateway get-export \
  --rest-api-id "$API_ID" \
  --stage-name dev \
  --export-type swagger \
  /apigateway/swagger.raw.json

# 2) Parchear para que "Try it out" apunte a LocalStack (desde el navegador)
python3 - <<'PY'
import json

with open("/apigateway/swagger.raw.json", "r", encoding="utf-8") as f:
    spec = json.load(f)

# ✅ Swagger 2.0: forzar host y http para que no se auto-apunte a swagger-ui
spec["host"] = "localhost:4566"
spec["schemes"] = ["http"]

# ✅ BasePath real del endpoint de LocalStack para apigateway "user_request_"
spec["basePath"] = "__BASE_PATH_REPLACE__"

# -----------------------------
# ✅ Añadir modelos si no existen
# (para que Swagger UI tenga un schema editable en PUT)
# -----------------------------
spec.setdefault("definitions", {})
spec["definitions"].setdefault("Todo", {
    "type": "object",
    "required": ["id", "todo", "status"],
    "properties": {
        "id": {"type": "string", "example": "1"},
        "todo": {"type": "string", "example": "Comprar pan"},
        "status": {"type": "string", "example": "open"}
    }
})

# -----------------------------
# ✅ Asegurar parameters en endpoints:
#   - PUT /todos => body (Todo)
#   - GET /todos/{id} => path param id
#   - DELETE /todos/{id} => path param id
# -----------------------------
paths = spec.setdefault("paths", {})

def ensure_responses(op: dict):
    op.setdefault("responses", {})
    op["responses"].setdefault("200", {"description": "OK"})

def ensure_consumes(op: dict):
    op.setdefault("consumes", ["application/json"])
    op.setdefault("produces", ["application/json"])

def ensure_body_param(op: dict, ref_name: str):
    op.setdefault("parameters", [])
    has_body = any(isinstance(p, dict) and p.get("in") == "body" for p in op["parameters"])
    if not has_body:
        op["parameters"].append({
            "name": "body",
            "in": "body",
            "required": True,
            "schema": {"$ref": f"#/definitions/{ref_name}"}
        })

def ensure_id_path_param(op: dict):
    op.setdefault("parameters", [])
    has_id = any(
        isinstance(p, dict)
        and p.get("in") == "path"
        and p.get("name") == "id"
        for p in op["parameters"]
    )
    if not has_id:
        op["parameters"].append({
            "name": "id",
            "in": "path",
            "required": True,
            "type": "string"
        })

# --- PUT /todos ---
if "/todos" in paths and isinstance(paths["/todos"], dict):
    put_op = paths["/todos"].get("put")
    if isinstance(put_op, dict):
        ensure_consumes(put_op)
        ensure_body_param(put_op, "Todo")
        ensure_responses(put_op)

# --- GET /todos/{id} ---
# A veces API Gateway exporta /todos/{id} tal cual. Si no existe, no lo inventamos.
if "/todos/{id}" in paths and isinstance(paths["/todos/{id}"], dict):
    get_op = paths["/todos/{id}"].get("get")
    if isinstance(get_op, dict):
        ensure_id_path_param(get_op)
        ensure_responses(get_op)

# --- DELETE /todos/{id} ---
if "/todos/{id}" in paths and isinstance(paths["/todos/{id}"], dict):
    del_op = paths["/todos/{id}"].get("delete")
    if isinstance(del_op, dict):
        ensure_id_path_param(del_op)
        ensure_responses(del_op)

# (Opcional) Añadir respuesta 200 si está vacío en cualquier operación
for p, methods in paths.items():
    if not isinstance(methods, dict):
        continue
    for m, op in methods.items():
        if isinstance(op, dict):
            ensure_responses(op)

with open("/apigateway/swagger.json", "w", encoding="utf-8") as f:
    json.dump(spec, f, indent=2)
PY

# 3) Reemplazar BASE_PATH con el API_ID real (bash sí lo tiene)
sed -i "s|__BASE_PATH_REPLACE__|/restapis/$API_ID/dev/_user_request_|g" /apigateway/swagger.json

echo "✅ swagger.json listo en /apigateway/swagger.json"
echo "   Swagger UI: http://localhost:8081"
