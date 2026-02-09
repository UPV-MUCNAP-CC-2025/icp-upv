# Infrastructure

This folder contains the CloudFormation templates needed to deploy the system on AWS. It is split into two stacks:

- `backend.yaml` for the API (API Gateway + Lambda) and IAM role.
- `frontend.yaml` for the static website hosting (S3 bucket + public read policy).

Everything here is designed to be minimal and easy to deploy from the AWS Console or AWS CLI.

## Prerequisites

- An AWS account with permissions for IAM, Lambda, API Gateway, S3, and CloudFormation.
- A DynamoDB table created outside CloudFormation (the backend template only reads from it).
- AWS region selected consistently for all resources.

## Backend

Template: `infrastructure/backend.yaml`

What it creates:

- IAM role for Lambda with `AWSLambdaBasicExecutionRole` plus permission to `Scan` a DynamoDB table.
- Lambda function (Python 3.12) that reads all items from the DynamoDB table and returns JSON.
- API Gateway REST API with `GET /hello` integrated as AWS_PROXY to the Lambda.
- API Gateway deployment and `prod` stage.

Important parameters:

- `AthletesTableName`: Name of the existing DynamoDB table. Default is `alucloud92`.

Behavior:

- Response body includes `count` and `athletes` array.
- CORS headers are enabled for `GET`.

Outputs:

- `InvokeURL`: The full URL for `GET /hello`.

Example response (shape):

```json
{
  "count": 2,
  "athletes": [
    { "id": "1", "nombre": "Ana", "estado": "activo" },
    { "id": "2", "nombre": "Luis", "estado": "inactivo" }
  ]
}
```

Notes:

- The Lambda uses `Scan`, so it reads the whole table. This is fine for small datasets but not ideal for large tables.
- The DynamoDB table must already exist and contain `id`, `nombre`, and `estado` attributes to match the response mapping.

## Frontend

Template: `infrastructure/frontend.yaml`

What it creates:

- S3 bucket configured for static website hosting.
- Bucket policy allowing public `s3:GetObject`.

Outputs:

- `BucketName`: The S3 bucket name.
- `WebsiteURL`: The public website endpoint.

Notes:

- The bucket name is fixed to `alucloud92-public-frontend` in the template, so it must be globally unique in S3.
- To update the site, upload your `index.html` and assets to the bucket.

## Deployment (CLI)

Backend:

```bash
aws cloudformation deploy \
  --template-file infrastructure/backend.yaml \
  --stack-name alucloud92-backend \
  --parameter-overrides AthletesTableName=alucloud92 \
  --capabilities CAPABILITY_NAMED_IAM
```

Frontend:

```bash
aws cloudformation deploy \
  --template-file infrastructure/frontend.yaml \
  --stack-name alucloud92-frontend
```

## Troubleshooting

- If the backend stack fails on IAM, ensure you passed `--capabilities CAPABILITY_NAMED_IAM`.
- If the frontend stack fails, the bucket name is likely already taken; update `BucketName` in `frontend.yaml`.
