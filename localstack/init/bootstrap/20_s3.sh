#!/usr/bin/env bash
set -euo pipefail

create_s3() {
  echo "📦 Creando bucket S3"
  awslocal s3 mb s3://todo-bucket || true
}