# GitOps-Driven Cloud-Native API Deployment

_Kubernetes · AWS · Terraform · GitHub Actions · Argo CD_

This repository demonstrates a **production-grade GitOps workflow** for deploying a cloud-native API on AWS using Kubernetes.  
Infrastructure is provisioned with Terraform, deployments are managed declaratively via Git, and CI/CD is fully automated.

---

## Architecture Overview

**Principles**

- Git as the single source of truth
- Infrastructure as Code using Terraform
- GitOps-based Continuous Delivery with Argo CD
- Secure, private-by-default networking
- Automated CI pipelines with security scanning

**Tech Stack**

- AWS (VPC, EKS, IAM, Load Balancers)
- Kubernetes
- Terraform (Remote State with S3 + DynamoDB)
- GitHub Actions (CI)
- Argo CD (CD)
- Traefik Ingress
- cert-manager (Let’s Encrypt)
- Bitnami Sealed Secrets
- Docker + GitHub Container Registry
- Trivy (Security Scanning)

---

## Repository Structure

```bash
.
├── terraform/                  # AWS Infrastructure (IaC)
│   ├── vpc/
│   ├── eks/
│   ├── iam/
│   ├── backend.tf              # S3 + DynamoDB remote state
│   └── main.tf
│
├── kubernetes/                 # Kubernetes manifests
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── ingress.yaml
│   ├── sealed-secret.yaml
│
├── .github/
│   └── workflows/
│       └── cicd.yml             # CI pipeline
│
└── README.md
```

---

## Infrastructure Provisioning (Terraform)

- Custom VPC with public and private subnets
- EKS cluster with managed node groups
- IAM roles and policies following least-privilege
- Load balancers and networking
- Remote state stored in S3 with DynamoDB state locking

---

## CI/CD Pipeline

### Continuous Integration (GitHub Actions)

1. Run tests
2. Security scanning using Trivy
3. Build Docker image
4. Push image to GitHub Container Registry
5. Update Kubernetes deployment manifests

### Continuous Delivery (Argo CD)

- Monitors Kubernetes manifests
- Syncs desired state automatically
- Prevents configuration drift

---

## Kubernetes Deployment

- Stateless API deployed via Deployment
- Cluster-internal Service
- External access via Traefik Ingress
- Worker nodes isolated in private subnets

---

## Ingress Controller (Traefik)

### Install Traefik

```bash
helm repo add traefik https://helm.traefik.io/traefik
helm repo update

helm install traefik traefik/traefik   --namespace traefik   --create-namespace
```

---

## TLS with cert-manager (Let’s Encrypt)

### Install cert-manager

```bash
helm repo add jetstack https://charts.jetstack.io
helm repo update

helm install cert-manager jetstack/cert-manager   --namespace cert-manager   --create-namespace   --set installCRDs=true
```

- Automatic HTTPS certificates
- Auto-renewal with Let’s Encrypt

---

## Secrets Management (Bitnami Sealed Secrets)

### Install Sealed Secrets

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

helm install sealed-secrets bitnami/sealed-secrets   --namespace kube-system
```

- Secrets encrypted before committing to Git
- Only decryptable by the target cluster

---

## Security Highlights

- Private EKS worker nodes
- No plaintext secrets in Git
- Automated vulnerability scanning
- TLS-enabled ingress
- Least-privilege IAM configuration

---

## Key Outcomes

- End-to-end GitOps workflow
- Reproducible infrastructure
- Secure, scalable Kubernetes deployment
- Production-ready CI/CD system

---

## Future Enhancements

- Canary deployments
- Horizontal Pod Autoscaling
- OPA / Gatekeeper policies
- Observability stack (Prometheus + Grafana)
