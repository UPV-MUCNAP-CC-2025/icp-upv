#!/usr/bin/env bash
set -euo pipefail

create_lambda() {
  echo "🧠 Creando Lambda"
  cd /backend
  zip -r /lambda/todo.zip lambda_function.py

  awslocal lambda create-function \
    --function-name todo-lambda \
    --runtime python3.12 \
    --handler lambda_function.lambda_handler \
    --role arn:aws:iam::000000000000:role/lambda-role \
    --zip-file fileb:///lambda/todo.zip \
  || true
}
