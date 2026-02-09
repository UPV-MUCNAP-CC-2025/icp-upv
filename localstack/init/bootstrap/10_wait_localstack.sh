#!/usr/bin/env bash
set -euo pipefail

wait_localstack() {
  echo "⏳ Esperando a LocalStack en $LS_ENDPOINT ..."
  until curl -sf "$LS_ENDPOINT/_localstack/health" >/dev/null; do
    sleep 1
  done
}
