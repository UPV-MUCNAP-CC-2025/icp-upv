#!/usr/bin/env bash
set -euo pipefail

# ==================================================
# CloudFormation stacks (and S3 buckets with same name)
# ==================================================
FRONT_STACK="alucloud92-public-frontend"
ARTIFACTS_STACK="alucloud92-lambda-artifacts"
APIGW_STACK="alucloud92-api-gateway"
LAMBDAS_STACK="alucloud92-lambdas"

# ==================================================
# 1) Empty S3 buckets (bucket name == stack name)
# ==================================================
for BUCKET in "$FRONT_STACK" "$ARTIFACTS_STACK"; do
  aws s3 rm "s3://$BUCKET" --recursive 2>/dev/null || true
done

# ==================================================
# 2) Delete stacks (order matters)
# ==================================================
for STACK in "$APIGW_STACK" "$FRONT_STACK" "$LAMBDAS_STACK" "$ARTIFACTS_STACK"; do
  aws cloudformation delete-stack --stack-name "$STACK" 2>/dev/null || true
  aws cloudformation wait stack-delete-complete --stack-name "$STACK" 2>/dev/null || true
done

echo "✅ Destroy complete"
