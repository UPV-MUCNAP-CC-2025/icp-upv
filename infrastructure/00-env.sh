#!/usr/bin/env bash
set -euo pipefail

# CloudFormation
export CFN_BUCKET_TEMPLATE="$ROOT_DIR/infrastructure/backend/10-lambda-artifacts-bucket.yaml"
export CFN_BUCKET_STACK="alucloud92-lambda-artifacts"

# Lambda
export CFN_LAMBDA_TEMPLATE="$ROOT_DIR/infrastructure/backend/20-lamba-deployment.yaml"
export CFN_LAMBDA_STACK="alucloud92-lambdas"
export LAMBDA_PY="$ROOT_DIR/app/backend/lambda_function.py"
export LAMBDA_ZIP="$ROOT_DIR/app/backend/lambda.zip"
export LAMBDA_S3_KEY="lambdas/lambda.zip"

# AWS
export AWS_DEFAULT_REGION="us-east-1"

# DynamoDB
export DYNAMODB_TABLE_NAME="alucloud92-todo-table"

# API Gateway
export CFN_APIGW_TEMPLATE="$ROOT_DIR/infrastructure/backend/30-api-gateway-deployment.yaml"
export CFN_APIGW_STACK="alucloud92-api-gateway"
