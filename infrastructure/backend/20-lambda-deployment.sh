#!/usr/bin/env bash
set -euo pipefail

deploy_lambda() {

  echo "=================================================="
  echo "🚀 Deploying stack: $CFN_LAMBDA_STACK"
  echo "=================================================="

  LAMBDA_S3_VERSION="$(aws s3api head-object \
    --bucket "$CFN_BUCKET_STACK" \
    --key "$LAMBDA_S3_KEY" \
    --query VersionId \
    --output text)"

  aws cloudformation deploy \
    --template-file $CFN_LAMBDA_TEMPLATE \
    --stack-name $CFN_LAMBDA_STACK \
    --capabilities CAPABILITY_IAM \
    --parameter-overrides \
      ToDoTableName="$DYNAMODB_TABLE_NAME" \
      LambdaCodeBucket="$CFN_BUCKET_STACK" \
      LambdaCodeKey="$LAMBDA_S3_KEY" \
      LambdaCodeVersion="$LAMBDA_S3_VERSION"

}