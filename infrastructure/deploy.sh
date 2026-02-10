#!/usr/bin/env bash
set -euo pipefail

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Variables comunes
source "$ROOT_DIR/00_env.sh"

# Pasos
source "$ROOT_DIR/backend/10-lambda-artifacts-bucket.sh";     create_artifact

echo "✅ Done"
