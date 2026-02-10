#!/usr/bin/env bash
set -euo pipefail

check_dynamodb() {
  aws dynamodb describe-table \
    --table-name alucloud92-todo-table \
    >/dev/null 2>&1 || {
      echo "ERROR: La tabla DynamoDB 'alucloud92-todo-table' NO existe."
      echo "Esta tabla es obligatoria para el despliegue."
      exit 1
    }

  echo "✅ DynamoDB table 'alucloud92-todo-table' existe"
}
