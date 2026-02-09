#!/usr/bin/env bash
set -euo pipefail

export_and_patch_swagger() {
  echo "🧾 Exportando y parcheando swagger para Swagger UI..."

  awslocal apigateway get-export \
    --rest-api-id "$API_ID" \
    --stage-name "$STAGE" \
    --export-type swagger \
    /apigateway/swagger.raw.json

  python3 - <<'PY'
import json

with open("/apigateway/swagger.raw.json", "r", encoding="utf-8") as f:
    spec = json.load(f)

spec["host"] = "localhost:4566"
spec["schemes"] = ["http"]
spec["basePath"] = "__BASE_PATH_REPLACE__"

spec.setdefault("definitions", {})
spec["definitions"].setdefault("Todo", {
    "type": "object",
    "required": ["id", "todo", "status"],
    "properties": {
        "id": {"type": "string", "example": "1"},
        "todo": {"type": "string", "example": "Comprar pan"},
        "status": {"type": "string", "example": "open"}
    }
})

paths = spec.setdefault("paths", {})

def ensure_responses(op: dict):
    op.setdefault("responses", {})
    op["responses"].setdefault("200", {"description": "OK"})

def ensure_consumes(op: dict):
    op.setdefault("consumes", ["application/json"])
    op.setdefault("produces", ["application/json"])

def ensure_body_param(op: dict, ref_name: str):
    op.setdefault("parameters", [])
    has_body = any(isinstance(p, dict) and p.get("in") == "body" for p in op["parameters"])
    if not has_body:
        op["parameters"].append({
            "name": "body",
            "in": "body",
            "required": True,
            "schema": {"$ref": f"#/definitions/{ref_name}"}
        })

def ensure_id_path_param(op: dict):
    op.setdefault("parameters", [])
    has_id = any(isinstance(p, dict) and p.get("in") == "path" and p.get("name") == "id" for p in op["parameters"])
    if not has_id:
        op["parameters"].append({"name": "id", "in": "path", "required": True, "type": "string"})

if "/todos" in paths and isinstance(paths["/todos"], dict):
    put_op = paths["/todos"].get("put")
    if isinstance(put_op, dict):
        ensure_consumes(put_op)
        ensure_body_param(put_op, "Todo")
        ensure_responses(put_op)

if "/todos/{id}" in paths and isinstance(paths["/todos/{id}"], dict):
    for method in ("get", "delete"):
        op = paths["/todos/{id}"].get(method)
        if isinstance(op, dict):
            ensure_id_path_param(op)
            ensure_responses(op)

for _, methods in paths.items():
    if not isinstance(methods, dict):
        continue
    for _, op in methods.items():
        if isinstance(op, dict):
            ensure_responses(op)

with open("/apigateway/swagger.json", "w", encoding="utf-8") as f:
    json.dump(spec, f, indent=2)
PY

  sed -i "s|__BASE_PATH_REPLACE__|/restapis/$API_ID/$STAGE/_user_request_|g" /apigateway/swagger.json

  echo "✅ swagger.json listo en /apigateway/swagger.json"
}
