# Reporte de trabajo (Infraestructura)

## Resumen general

Se ha definido la infraestructura del proyecto en AWS mediante plantillas de CloudFormation y se ha preparado un frontend estático para consumir el endpoint de la API. La documentación en `infrastructure/README.md` explica la arquitectura, parámetros, despliegue y notas operativas.

## Infraestructura backend (API)

Archivo: `infrastructure/backend.yaml`

Se creó una plantilla de CloudFormation que despliega:

- Un rol de IAM para Lambda con permisos básicos y permiso de lectura (`Scan`) sobre una tabla DynamoDB existente.
- Una función Lambda en Python 3.12 que:
  - Lee todos los registros de la tabla DynamoDB indicada por parámetro.
  - Transforma los datos a una lista de atletas (`id`, `nombre`, `estado`).
  - Responde con JSON y cabeceras CORS habilitadas.
- Un API Gateway REST con el recurso `/hello` y método `GET`, integrado con la Lambda (AWS_PROXY).
- Despliegue y `stage` llamado `prod`.

Parámetro clave:

- `AthletesTableName`: nombre de la tabla DynamoDB existente (por defecto `alucloud92`).

Salida del stack:

- `InvokeURL`: URL del endpoint `/prod/hello`.

## Infraestructura frontend (web estática)

Archivo: `infrastructure/frontend.yaml`

Se creó una plantilla de CloudFormation que despliega:

- Un bucket S3 con hosting de sitio web estático.
- Política pública para permitir `s3:GetObject` a cualquier usuario.

Salidas del stack:

- `BucketName`: nombre del bucket.
- `WebsiteURL`: endpoint público del sitio web.

Nota: el nombre del bucket es fijo en la plantilla (`alucloud92-public-frontend`), por lo que debe ser único globalmente.

## Frontend de prueba

Archivo: `infrastructure/index.html`

Se preparó una página web sencilla para probar el endpoint `/hello`:

- Botón para llamar al endpoint.
- Muestra estado HTTP, cabeceras y cuerpo de respuesta.
- Endpoint configurado en el script para el API Gateway.

## Documentación

Archivo: `infrastructure/README.md`

Se añadió documentación con:

- Descripción de los dos stacks (backend y frontend).
- Prerrequisitos y parámetros.
- Ejemplos de respuesta del endpoint.
- Comandos de despliegue por CLI.
- Notas y troubleshooting.
