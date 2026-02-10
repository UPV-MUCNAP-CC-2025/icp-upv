#!/usr/bin/env bash
set -euo pipefail

# CloudFormation
export CFN_BUCKET_TEMPLATE="$ROOT_DIR/backend/10-lambda-artifacts-bucket.yaml"
export CFN_BUCKET_STACK="alucloud92-lambda-artifacts"

# Lambda
export LAMBDA_PY="$ROOT_DIR/app/backend/lambda_function.py"
export LAMBDA_ZIP="$ROOT_DIR/app/backend/lambda.zip"
export LAMBDA_S3_KEY="lambdas/lambda.zip"

# AWS
export AWS_DEFAULT_REGION="us-east-1"
