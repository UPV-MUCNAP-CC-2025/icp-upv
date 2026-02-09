#!/usr/bin/env bash
set -euo pipefail

create_apigw() {
  echo "🌍 Creando API Gateway"

  API_ID="$(awslocal apigateway create-rest-api --name "$API_NAME" --query 'id' --output text)"

  ROOT_ID="$(awslocal apigateway get-resources \
    --rest-api-id "$API_ID" \
    --query 'items[0].id' \
    --output text)"

  RESOURCE_ID="$(awslocal apigateway create-resource \
    --rest-api-id "$API_ID" \
    --parent-id "$ROOT_ID" \
    --path-part todos \
    --query 'id' \
    --output text)"

  # GET /todos
  awslocal apigateway put-method --rest-api-id "$API_ID" --resource-id "$RESOURCE_ID" --http-method GET --authorization-type NONE
  awslocal apigateway put-integration --rest-api-id "$API_ID" --resource-id "$RESOURCE_ID" --http-method GET \
    --type AWS_PROXY --integration-http-method POST \
    --uri "arn:aws:apigateway:$REGION:lambda:path/2015-03-31/functions/arn:aws:lambda:$REGION:000000000000:function:todo-lambda/invocations"

  # PUT /todos
  awslocal apigateway put-method --rest-api-id "$API_ID" --resource-id "$RESOURCE_ID" --http-method PUT --authorization-type NONE
  awslocal apigateway put-integration --rest-api-id "$API_ID" --resource-id "$RESOURCE_ID" --http-method PUT \
    --type AWS_PROXY --integration-http-method POST \
    --uri "arn:aws:apigateway:$REGION:lambda:path/2015-03-31/functions/arn:aws:lambda:$REGION:000000000000:function:todo-lambda/invocations"

  # /todos/{id}
  TODO_ID_RES_ID="$(awslocal apigateway create-resource \
    --rest-api-id "$API_ID" \
    --parent-id "$RESOURCE_ID" \
    --path-part "{id}" \
    --query 'id' \
    --output text)"

  # GET /todos/{id}
  awslocal apigateway put-method --rest-api-id "$API_ID" --resource-id "$TODO_ID_RES_ID" --http-method GET --authorization-type NONE
  awslocal apigateway put-integration --rest-api-id "$API_ID" --resource-id "$TODO_ID_RES_ID" --http-method GET \
    --type AWS_PROXY --integration-http-method POST \
    --uri "arn:aws:apigateway:$REGION:lambda:path/2015-03-31/functions/arn:aws:lambda:$REGION:000000000000:function:todo-lambda/invocations"

  # DELETE /todos/{id}
  awslocal apigateway put-method --rest-api-id "$API_ID" --resource-id "$TODO_ID_RES_ID" --http-method DELETE --authorization-type NONE
  awslocal apigateway put-integration --rest-api-id "$API_ID" --resource-id "$TODO_ID_RES_ID" --http-method DELETE \
    --type AWS_PROXY --integration-http-method POST \
    --uri "arn:aws:apigateway:$REGION:lambda:path/2015-03-31/functions/arn:aws:lambda:$REGION:000000000000:function:todo-lambda/invocations"

  # Modelo + request model en PUT
  awslocal apigateway create-model \
    --rest-api-id "$API_ID" \
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
    --rest-api-id "$API_ID" \
    --resource-id "$RESOURCE_ID" \
    --http-method PUT \
    --patch-operations op=replace,path=/requestModels/application~1json,value=TodoModel || true

  awslocal apigateway create-deployment --rest-api-id "$API_ID" --stage-name "$STAGE"
}
