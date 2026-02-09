
## Entorno local con LocalStack

### Qué se levanta
El `docker-compose.yml` arranca:
- `localstack` en `http://localhost:4566` con servicios: `dynamodb`, `lambda`, `apigateway`, `logs`.
- `dynamodb-admin` en `http://localhost:8001`.
- `swagger-ui` en `http://localhost:8081`.
- `minio` en `http://localhost:9000` (consola en `http://localhost:9001`).
- `frontend` (Vite) en `http://localhost:5173`.

### Cómo se inicializa
Al iniciar LocalStack se ejecuta `localstack/init/init.sh`, que:
- Crea el bucket S3 `hello-bucket`.
- Crea la tabla DynamoDB `todos`.
- Empaqueta la Lambda desde `app/backend/lambda_function.py` y crea `todo-lambda`.
- Crea un API Gateway REST llamado `todo-api` con rutas `GET /todos`, `PUT /todos`, `GET /todos/{id}` y `DELETE /todos/{id}`.
- Exporta el Swagger y lo adapta para Swagger UI.

El frontend espera a que el API exista mediante `app/frontend/wait-for-apigw.sh`, detecta el `API_ID` en LocalStack y genera `VITE_API_BASE_URL`, que Vite usa como proxy para `/todos`.

### Cómo iniciarlo
Requisitos:
- Docker y Docker Compose.

Comando:
```bash
docker compose up --build
```

Endpoints útiles:
- App: `http://localhost:5173`
- API base (LocalStack): `http://localhost:4566/restapis/<API_ID>/dev/_user_request_`
- Swagger UI: `http://localhost:8081`
- DynamoDB Admin: `http://localhost:8001`

Para detener:
```bash
docker compose down
```

### Probar la API rápidamente
```bash
# listar todos
curl -s http://localhost:4566/restapis/<API_ID>/dev/_user_request_/todos

# crear/actualizar
curl -s -X PUT http://localhost:4566/restapis/<API_ID>/dev/_user_request_/todos \
  -H 'Content-Type: application/json' \
  -d '{"id":"1","todo":"Comprar pan","status":"pendiente"}'

# obtener por id
curl -s http://localhost:4566/restapis/<API_ID>/dev/_user_request_/todos/1

# borrar
curl -s -X DELETE http://localhost:4566/restapis/<API_ID>/dev/_user_request_/todos/1
```

Nota: si necesitas el `API_ID`, revisa los logs del contenedor `frontend` o `localstack` al arrancar; también puedes verlo en Swagger UI.

## Desarrollo sin Docker (frontend)
Requisitos:
- Node.js.

Pasos:
```bash
cd app/frontend
npm install

# en otra terminal, asegura LocalStack arriba
# exporta el endpoint local (ejemplo):
export VITE_API_BASE_URL=http://localhost:4566/restapis/<API_ID>/dev/_user_request_

npm run dev
```
