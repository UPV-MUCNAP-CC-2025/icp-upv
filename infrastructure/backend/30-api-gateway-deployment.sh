#!/usr/bin/env bash
set -euo pipefail

deploy_apigw() {

  echo "=================================================="
  echo "🚀 Deploying stack: $CFN_APIGW_STACK"
  echo "=================================================="

  aws cloudformation deploy \
    --template-file $CFN_APIGW_TEMPLATE \
    --stack-name $CFN_APIGW_STACK
}
