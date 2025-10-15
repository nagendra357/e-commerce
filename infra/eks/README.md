# EKS + E-commerce App (Angular + Python + MySQL)

## Structure
- `modules/` Terraform modules for VPC, IAM, EKS, self-managed node group
- `k8s/ecommerce/` Kubernetes manifests (10-container app)
- `src/` Source code
  - `frontend-angular/` Nginx placeholder for Angular dist
  - `common/` Shared Python helpers (DB + settings)
  - `services/` FastAPI microservices (`auth`, `users`, `catalog`, `cart`, `orders`, `payments`, `inventory`)

## Terraform
```
terraform init
terraform plan
terraform apply
```
Ensure you have AWS CLI and kubectl installed. Kubeconfig is updated automatically in Terraform via `null_resource.apply_aws_auth`.

## Build and push images
Set your registry (ECR, GHCR, Docker Hub) and tag:
```
$env:REGISTRY="your-registry"   # e.g. 123456789012.dkr.ecr.us-east-1.amazonaws.com
$env:TAG="v1"

# Login as needed for your registry before pushing

# Build Python services
foreach ($svc in "auth","users","catalog","cart","orders","payments","inventory") {
  docker build -t $env:REGISTRY/ecommerce-$svc:$env:TAG -f src/services/$svc/Dockerfile src/services/$svc
  docker push $env:REGISTRY/ecommerce-$svc:$env:TAG
}

# Build frontend (serves Angular dist placeholder)
docker build -t $env:REGISTRY/ecommerce-frontend:$env:TAG -f src/frontend-angular/Dockerfile src/frontend-angular
docker push $env:REGISTRY/ecommerce-frontend:$env:TAG
```

## Update Kubernetes images
Edit the following files to set your image names/tags:
- `k8s/ecommerce/auth.yaml`
- `k8s/ecommerce/users.yaml`
- `k8s/ecommerce/catalog.yaml`
- `k8s/ecommerce/cart.yaml`
- `k8s/ecommerce/orders.yaml`
- `k8s/ecommerce/payments.yaml`
- `k8s/ecommerce/inventory.yaml`
- `k8s/ecommerce/frontend.yaml` (nginx for Angular)

Example (auth):
```
image: 123456789012.dkr.ecr.us-east-1.amazonaws.com/ecommerce-auth:v1
```

## Deploy to EKS
```
aws eks update-kubeconfig --name demo-eks --region us-east-1
kubectl apply -f k8s/ecommerce/namespace.yaml
kubectl apply -f k8s/ecommerce/secrets.yaml
kubectl apply -f k8s/ecommerce/mysql.yaml
kubectl apply -f k8s/ecommerce/api-gateway-config.yaml
kubectl apply -f k8s/ecommerce/api-gateway.yaml
kubectl apply -f k8s/ecommerce/auth.yaml
kubectl apply -f k8s/ecommerce/users.yaml
kubectl apply -f k8s/ecommerce/catalog.yaml
kubectl apply -f k8s/ecommerce/cart.yaml
kubectl apply -f k8s/ecommerce/orders.yaml
kubectl apply -f k8s/ecommerce/payments.yaml
kubectl apply -f k8s/ecommerce/inventory.yaml
kubectl apply -f k8s/ecommerce/frontend-config.yaml
kubectl apply -f k8s/ecommerce/frontend.yaml
```

Get the frontend URL:
```
kubectl -n ecommerce get svc frontend
```

## Environment variables (services)
- `DB_HOST`, `DB_NAME`, `DB_USER`, `DB_PASSWORD`
- `JWT_SECRET` (auth service)

These are provided by `k8s/ecommerce/secrets.yaml`. Update them for production.

## Notes
- Python services use `FastAPI` + `uvicorn`, `pymysql` to talk to MySQL.
- Very simple DB table creation is done on first request for demo purposes. Replace with proper migrations.
- Frontend is a placeholder Nginx serving `src/frontend-angular/dist/index.html`. Replace with your Angular build output.
