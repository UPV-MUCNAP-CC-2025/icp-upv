#!/usr/bin/env bash
set -euo pipefail

print_summary() {
  echo ""
  echo "✅ API lista:"
  echo "👉 http://localhost:4566/restapis/$API_ID/$STAGE/_user_request_"
  echo "   Swagger UI: http://localhost:8081"
}
