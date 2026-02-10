#!/usr/bin/env bash
set -euo pipefail

create_frontend() {

  echo "=================================================="
  echo "🚀 Deploying stack: $CFN_FRONT_STACK"
  echo "=================================================="

  aws cloudformation deploy \
    --template-file "$CFN_FRONT_TEMPLATE" \
    --stack-name "$CFN_FRONT_STACK"

  (cd app/frontend && npm ci && npm run build)
  aws s3 sync app/frontend/dist "s3://$CFN_FRONT_STACK" --delete

}
