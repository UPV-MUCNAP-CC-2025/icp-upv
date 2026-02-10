#!/usr/bin/env bash
set -euo pipefail

deploy_lambda() {
  aws cloudformation deploy \
    --template-file "$CFN_BUCKET_TEMPLATE" \
    --stack-name "$CFN_BUCKET_STACK"

  zip -j "$LAMBDA_ZIP" "$LAMBDA_PY"
  aws s3 cp "$LAMBDA_ZIP" "s3://$CFN_BUCKET_STACK/$LAMBDA_S3_KEY"

  aws cloudformation deploy \
    --template-file $CFN_LAMBDA_TEMPLATE \
    --stack-name $CFN_LAMBDA_STACK \
    --capabilities CAPABILITY_IAM \
    --parameter-overrides \
      ToDoTableName="$DYNAMODB_TABLE_NAME" \
      LambdaCodeBucket="$CFN_BUCKET_STACK" \
      LambdaCodeKey="$LAMBDA_S3_KEY"

}