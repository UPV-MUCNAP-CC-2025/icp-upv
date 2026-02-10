#!/usr/bin/env bash
set -euo pipefail

create_artifact() {

  echo "Deploying stack: $CFN_BUCKET_STACK"

  aws cloudformation deploy \
    --template-file "$CFN_BUCKET_TEMPLATE" \
    --stack-name "$CFN_BUCKET_STACK"

  zip -j "$LAMBDA_ZIP" "$LAMBDA_PY"
  aws s3 cp "$LAMBDA_ZIP" "s3://$CFN_BUCKET_STACK/$LAMBDA_S3_KEY"
}
