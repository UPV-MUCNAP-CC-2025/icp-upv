#!/usr/bin/env bash
set -euo pipefail

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Variables comunes
source "$ROOT_DIR/infrastructure/00-env.sh"

# Pasos
source "$ROOT_DIR/infrastructure/backend/00-check-dynamodb-table.sh"; check_dynamodb
source "$ROOT_DIR/infrastructure/backend/10-lambda-artifacts-bucket.sh"; create_artifact

echo "✅ Done"
