# Kubernetes Data Platform (with CI/CD)

This project migrates and extends the [Lambda Data Platform](https://github.com/pyvel26/Lambda-Inspired-Platform.git) from Docker Compose to **Kubernetes**, demonstrating cloud-native migration patterns and distributed systems orchestration. The platform maintains the same Lambda architecture with real-time streaming and scheduled batch processing, now deployed with enterprise-grade container orchestration and **Infrastructure as Code (Terraform)**.

---

## Architecture Migration
**Migration Path:** Docker Compose → Kubernetes + Terraform

Gains in Kubernetes:
- **Pod scaling** with replica sets
- **Service networking** with DNS-based discovery
- **Persistent storage** with PV/PVC management
- **Infrastructure as Code** with Terraform
- **Dependency management** with initContainers

---

## Components

### Real-time Stream Processing
- **lambda-producer-stream** (3 replicas): Generates live transaction data and streams to Kafka  
- **kafka-service**: Message broker with **ZooKeeper** coordination  
- **lambda-consumer** (3 replicas): Consumes Kafka streams and writes to **PostgreSQL**

### Scheduled Batch Processing
- **csv-batch-cron**: CronJob scheduling batch processing at midnight  
- **lambda-csv-batch**: Processes batch transaction data with job tracking

### Data Management
- **lambda-postgres** (3 replicas): PostgreSQL for transaction storage  
- **lambda-pgadmin**: Database management and monitoring interface  
- **db-setup-job**: One-time schema initialization job

### Infrastructure Services
- **zookeeper**: Kafka coordination and metadata management  
- **kafka-service**: Message streaming with persistent storage

---

## Data Flow

**Stream Path:**  
Live Data → **lambda-producer-stream** → **kafka-service** → **lambda-consumer** → **lambda-postgres**

**Batch Path:**  
CronJob (midnight) → **csv-batch-cron** → **lambda-csv-batch** → **lambda-postgres**

**Management:**  
**db-setup-job** → PostgreSQL Schema  
**lambda-pgadmin** → Database Monitoring

---

## CI/CD (Terraform)
A GitHub Actions workflow validates Terraform changes on every push/PR:
- `terraform init` → provider/backend setup  
- `terraform fmt -check` → formatting enforcement  
- `terraform validate` → syntax/structure checks  
- **TFLint** → best-practice linting  
- `terraform plan` (CI-safe, no refresh) → preview changes

> Apply is run locally for Minikube; future improvement is remote apply against a managed cluster.

---
## Tech Stack

**Container Orchestration:**
- Kubernetes
- Terraform
- Minikube
- Docker

**Data Platform:**
- Apache Kafka + ZooKeeper
- PostgreSQL
- pgAdmin
- Python 3.11

**Observability:**
- Kubernetes metrics-server
- kubectl monitoring
- Container resource limits

---

## Quick Start

```bash
# Deploy with Terraform
cd terraform
terraform init
terraform plan
terraform apply

# Verify
kubectl get pods -n dev
kubectl get services -n dev
