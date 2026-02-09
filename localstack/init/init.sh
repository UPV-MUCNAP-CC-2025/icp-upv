#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Carga variables y helpers
source "$ROOT_DIR/bootstrap/00_env.sh"

# Ejecuta pasos
source "$ROOT_DIR/bootstrap/10_wait_localstack.sh"; wait_localstack
source "$ROOT_DIR/bootstrap/20_s3.sh";            create_s3
source "$ROOT_DIR/bootstrap/30_dynamodb.sh";      create_dynamodb
source "$ROOT_DIR/bootstrap/40_lambda.sh";        create_lambda
source "$ROOT_DIR/bootstrap/50_apigw.sh";         create_apigw
source "$ROOT_DIR/bootstrap/60_swagger.sh";       export_and_patch_swagger
source "$ROOT_DIR/bootstrap/99_print.sh";         print_summary
