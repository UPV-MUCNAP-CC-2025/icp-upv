#!/usr/bin/env bash
set -euo pipefail

LS_ENDPOINT="${LS_ENDPOINT:-http://localstack:4566}"
REGION="${AWS_DEFAULT_REGION:-eu-west-1}"
STAGE="${API_STAGE:-dev}"
API_NAME="${API_NAME:-todo-api}"

export AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID:-test}"
export AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY:-test}"
export AWS_DEFAULT_REGION="$REGION"

# Variables que se irán rellenando
API_ID=""
ROOT_ID=""
RESOURCE_ID=""
TODO_ID_RES_ID=""
