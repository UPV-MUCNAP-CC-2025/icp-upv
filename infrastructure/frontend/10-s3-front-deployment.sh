#!/usr/bin/env bash
set -euo pipefail

create_frontend() {

  echo "=================================================="
  echo "🚀 Deploying stack: $CFN_FRONT_STACK"
  echo "=================================================="

  aws cloudformation deploy \
    --template-file "$CFN_FRONT_TEMPLATE" \
    --stack-name "$CFN_FRONT_STACK"

  API_URL="$(aws cloudformation describe-stacks \
    --stack-name "$CFN_APIGW_STACK" \
    --query "Stacks[0].Outputs[?OutputKey=='TodosBaseUrl'].OutputValue | [0]" \
    --output text)"

  (cd "$ROOT_DIR/app/frontend" \
    && export VITE_API_BASE_URL="$API_URL" \
    && npm ci \
    && npm run build)
    
  aws s3 sync $ROOT_DIR/app/frontend/dist "s3://$CFN_FRONT_STACK" --delete

}
