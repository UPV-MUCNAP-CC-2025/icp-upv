#!/usr/bin/env bash
set -euo pipefail

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Variables comunes
source "$ROOT_DIR/infrastructure/00-env.sh"

# Pasos backend
source "$ROOT_DIR/infrastructure/backend/00-check-dynamodb-table.sh"; check_dynamodb
source "$ROOT_DIR/infrastructure/backend/10-lambda-artifacts-bucket.sh"; create_artifact
source "$ROOT_DIR/infrastructure/backend/20-lambda-deployment.sh"; deploy_lambda
source "$ROOT_DIR/infrastructure/backend/30-api-gateway-deployment.sh"; deploy_apigw

# Pasos frontend
source "$ROOT_DIR/infrastructure/frontend/10-s3-front-deployment.sh"; create_frontend

echo "✅ Done"
