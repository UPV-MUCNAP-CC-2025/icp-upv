# Infrastructure

Este directorio contiene toda la definición y automatización de la **infraestructura en AWS** del proyecto, utilizando **AWS CloudFormation** y **scripts Bash** para facilitar el despliegue, verificación y eliminación de los recursos necesarios.

El objetivo de esta carpeta es permitir el **despliegue reproducible** de una arquitectura **serverless** en un entorno real de AWS, equivalente a la utilizada durante el desarrollo local con LocalStack.

## Requisitos

Debido a las restricciones que presentan las cuentas de estudiantes del MUCNAP en AWS, no es posible crear tablas de DynamoDB en CloudFormation, ya que se necesita el persmiso de *DescribeTables* y el usuario no dispone del mismo. 

Como alternativa se require que la tabla **alucloud92-todo-table** sea creada con anterioridad al despliegue. El script `infrastructure/backend/00-check-dynamodb-table.sh` es el encargado de comprobar que el recurso existe con anterioridad a la creación de los diferentes stacks de CloudFormation.

## Estructura del directorio

```
infrastructure/
├── 00-env.sh
├── deploy.sh
├── destroy.sh
├── backend/
│   ├── 00-check-dynamodb-table.sh
│   ├── 10-lambda-artifacts-bucket.yaml
│   ├── 10-lambda-artifacts-bucket.sh
│   ├── 20-lambda-deployment.yaml
│   ├── 20-lambda-deployment.sh
│   ├── 30-api-gateway-deployment.yaml
│   └── 30-api-gateway-deployment.sh
└── frontend/
    ├── 10-s3-front-deployment.yaml
    └── 10-s3-front-deployment.sh
```

---

## Backend

El subdirectorio `backend/` contiene los recursos necesarios para desplegar la API y su lógica de negocio:

- **Bucket de artefactos Lambda**: almacenamiento de los paquetes ZIP de las funciones.
- **Función AWS Lambda**: implementación de la lógica CRUD y configuración IAM.
- **API Gateway**: definición de recursos, métodos HTTP e integración con Lambda.
- **Scripts de verificación**: comprobaciones previas sobre DynamoDB.

---

## Frontend

El subdirectorio `frontend/` contiene la definición de la infraestructura necesaria para servir el cliente web:

- **Amazon S3 Static Website Hosting** para alojar el frontend desarrollado en React.

---

## Despliegue

```bash
cd infrastructure
./deploy.sh
```

---

## Eliminación de la infraestructura

```bash
source 00-env.sh
./destroy.sh
```
