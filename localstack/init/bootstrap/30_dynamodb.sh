#!/usr/bin/env bash
set -euo pipefail

create_dynamodb() {
  echo "🗄️ Creando tabla DynamoDB"
  awslocal dynamodb create-table \
    --table-name todos \
    --attribute-definitions AttributeName=id,AttributeType=S \
    --key-schema AttributeName=id,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
  || true
}
