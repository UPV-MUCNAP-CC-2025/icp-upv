#!/usr/bin/env sh
set -eu

LS_ENDPOINT="http://localstack:4566"
REGION="${AWS_DEFAULT_REGION:-us-east-1}"
STAGE="${API_STAGE:-dev}"

API_NAME="${API_NAME:-todo-api}"

export AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID:-test}"
export AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY:-test}"
export AWS_DEFAULT_REGION="$REGION"

echo "⏳ Esperando a LocalStack en $LS_ENDPOINT ..."
until curl -sf "$LS_ENDPOINT/_localstack/health" >/dev/null; do
  sleep 1
done

echo "⏳ Buscando REST API '$API_NAME' via AWS CLI..."
while :; do
  API_ID="$(aws --endpoint-url="$LS_ENDPOINT" apigateway get-rest-apis \
    --query "items[?name=='$API_NAME'].id | [0]" \
    --output text 2>/dev/null || true)"

  if [ -n "${API_ID:-}" ] && [ "$API_ID" != "None" ]; then
    break
  fi

  echo "  ...todavía no aparece (reintentando)"
  sleep 1
done

VITE_API_BASE_URL="$LS_ENDPOINT/restapis/$API_ID/$STAGE/_user_request_"
export VITE_API_BASE_URL

echo "✅ API_ID=$API_ID"
echo "✅ VITE_API_BASE_URL=$VITE_API_BASE_URL"

# Para debug
echo "VITE_API_BASE_URL=$VITE_API_BASE_URL" > /app/.env.local
