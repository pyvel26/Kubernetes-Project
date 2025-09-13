# Kubernetes Data Platform (with CI/CD)

This project migrates and extends the [Lambda Data Platform](https://github.com/pyvel26/Lambda-Inspired-Platform.git) from Docker Compose to Kubernetes, demonstrating cloud-native migration patterns and distributed systems orchestration. The platform maintains the same Lambda architecture with real-time streaming and scheduled batch processing, now deployed with enterprise-grade container orchestration.

---

## Architecture Migration

**Migration Path**: Docker Compose → Kubernetes + Terraform

The core Lambda architecture remains unchanged while gaining Kubernetes capabilities:
- **Pod scaling** with replica sets
- **Service networking** with DNS-based discovery  
- **Persistent storage** with PV/PVC management
- **Infrastructure as Code** with Terraform
- **Dependency management** with initContainers

---

## Components

### Real-time Stream Processing:
- **lambda-producer-stream** (3 replicas): Generates live transaction data and streams to Kafka
- **kafka-service**: Message broker with ZooKeeper coordination
- **lambda-consumer** (3 replicas): Consumes Kafka streams and writes to PostgreSQL

### Scheduled Batch Processing:
- **csv-batch-cron**: CronJob scheduling batch processing at midnight
- **lambda-csv-batch**: Processes batch transaction data with job tracking

### Data Management:
- **lambda-postgres** (3 replicas): PostgreSQL cluster for transaction storage
- **lambda-pgadmin**: Database management and monitoring interface
- **db-setup-job**: One-time schema initialization job

### Infrastructure Services:
- **zookeeper**: Kafka coordination and metadata management
- **kafka-service**: Message streaming with persistent storage

---

## Data Flow

### Stream Path:
Live Data → lambda-producer-stream → kafka-service → lambda-consumer → lambda-postgres

### Batch Path:  
CronJob (midnight) → csv-batch-cron → lambda-csv-batch → lambda-postgres

### Management:
db-setup-job → PostgreSQL Schema  
lambda-pgadmin → Database Monitoring

---

## Kubernetes Implementation

### Networking:
- **Services**: ClusterIP for internal communication, NodePort for external access
- **DNS Discovery**: Pods communicate via service names (kafka-service:9092)
- **Load Balancing**: Traffic distribution across replicas

### Storage:
- **Persistent Volumes**: Kafka and Postgres data persistence
- **Volume Claims**: Dynamic storage provisioning

### Orchestration:
- **Deployments**: Replica management for applications
- **Jobs/CronJobs**: Batch processing automation
- **InitContainers**: Dependency management and startup ordering
- **Secrets**: Environment configuration management

---

## Infrastructure as Code

**Technology Stack:**
- **Kubernetes**: Container orchestration
- **Terraform**: Infrastructure provisioning and management
- **Minikube**: Local development cluster
- **Docker**: Container runtime and image management

---

## Key Technical Challenges Solved

### 1. **Dependency Management**
- **Problem**: Services starting before dependencies (Kafka before ZooKeeper)
- **Solution**: InitContainers with health checks using `nc -zv` port testing

### 2. **Storage Persistence** 
- **Problem**: Data loss on pod restarts, corrupted volume states
- **Solution**: Proper PV/PVC lifecycle management with storage classes

### 3. **Service Discovery**
- **Problem**: Hardcoded localhost connections breaking in distributed environment
- **Solution**: Kubernetes DNS with service-based addressing (kafka-service:9092)

### 4. **Configuration Management**
- **Problem**: Environment-specific secrets and configuration
- **Solution**: Kubernetes Secrets with base64 encoding and envFrom injection

---

## Quick Start

### Prerequisites
```bash
# Install required tools
minikube start
terraform --version
kubectl version --client
```

### Deployment
```bash
# Clone repository
git clone <repository-url>
cd kubernetes-data-platform

# Deploy infrastructure
cd terraform
terraform init
terraform plan
terraform apply

# Verify deployment
kubectl get pods -n dev
kubectl get services -n dev

# Access pgAdmin (CGNAT-friendly)
kubectl port-forward svc/lambda-pgadmin 5050:5050 -n dev
# Browser: http://localhost:5050
```

### Manual Testing
```bash
# Test batch processing
kubectl create job test-batch --from=cronjob/csv-batch-cron -n dev

# Monitor resources
kubectl top pods -n dev
kubectl top nodes

# Check logs
kubectl logs -f deployment/lambda-producer-stream -n dev
kubectl logs -f deployment/lambda-consumer -n dev
```

---

## Services & Access

| Component | Type | Access Method | Purpose |
|-----------|------|---------------|---------|
| kafka-service | Service | kafka-service:9092 | Message streaming |
| lambda-postgres | Service | lambda-postgres:5432 | Data storage |
| lambda-pgadmin | Service (NodePort) | `kubectl port-forward` | DB management |
| zookeeper | Service | zookeeper:2181 | Kafka coordination |
| Producer Stream | Deployment | N/A | Transaction data generation |
| Consumer Stream | Deployment | N/A | Stream processing |
| Cron Batch | CronJob | N/A | Scheduled batch processing |
| CSV Batch | Job | N/A | Batch data processing |
| DB Setup | Job | N/A | Schema initialization |

**pgAdmin Access**: Use port-forwarding due to CGNAT network restrictions  
**Credentials**: Stored in Kubernetes secrets with base64 encoding

---

## Operational Commands

### Monitoring
```bash
# Real-time resource usage
watch kubectl top pods -n dev

# Service endpoints
kubectl get endpoints -n dev

# Pod scaling
kubectl scale deployment lambda-consumer --replicas=5 -n dev
```

### Troubleshooting
```bash
# Debug pod issues
kubectl describe pod <pod-name> -n dev
kubectl logs <pod-name> -c <container-name> -n dev --previous

# Network connectivity
kubectl exec <pod-name> -n dev -- nc -zv kafka-service 9092

# Storage issues
kubectl get pv,pvc -n dev
kubectl describe pvc kafka-pvc -n dev
```

### Cleanup
```bash
# Destroy infrastructure
terraform destroy

# Force cleanup if needed
kubectl delete namespace dev --force --grace-period=0
```

---

## Project Structure

```
Kubernetes-Project/
├── kubernetes/
│   ├── deployments/
│   │   ├── consumer-stream.yaml
│   │   ├── kafka.yaml
│   │   ├── pgadmin.yaml
│   │   ├── postgres.yaml
│   │   ├── producer-stream.yaml
│   │   └── zookeeper.yaml
│   ├── services/
│   │   ├── kafka.yaml
│   │   ├── pgadmin-service.yaml
│   │   ├── postgres.yaml
│   │   └── zoo-service.yaml
│   ├── jobs/
│   │   ├── cron-batch.yaml
│   │   └── db-setup-job.yaml
│   ├── secrets/
│   │   └── database-secrets.yaml
│   ├── volumes/
│   │   ├── kafka-pvc.yaml
│   │   └── postgres-pvc.yaml
│   └── namespace.yaml
├── terraform/
│   ├── batch.tf
│   ├── core.tf
│   ├── foundation.tf
│   ├── job_admin.tf
│   ├── providers.tf
│   ├── stream.tf
│   └── terraform.tfstate
└── README.md
```

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

## Learning Objectives

This migration project demonstrates:

**Kubernetes Concepts:**
- Pod lifecycle management and replica scaling
- Service networking and DNS resolution
- Persistent volume management and storage classes
- Job scheduling with CronJobs
- ConfigMap and Secret management
- Resource quotas and limits

**DevOps Practices:**
- Infrastructure as Code with Terraform
- Container orchestration patterns
- Dependency management in distributed systems
- Monitoring and observability setup
- Environment configuration management

**Distributed Systems:**
- Container networking and service discovery
- Data persistence in container environments
- Load balancing and traffic routing
- Fault tolerance and recovery patterns

---

## Performance Considerations

**Scaling Strategy:**
- **Producers**: Scale based on data generation requirements
- **Consumers**: Scale based on Kafka partition count and throughput
- **Database**: Vertical scaling with resource limits, horizontal with read replicas

**Resource Optimization:**
- InitContainers minimize startup race conditions
- Resource requests prevent resource starvation
- Resource limits prevent resource exhaustion
- Persistent volumes ensure data durability

---

## Migration Notes

**From Docker Compose to Kubernetes:**
- **Networking**: localhost → service-based DNS resolution
- **Storage**: bind mounts → persistent volume claims
- **Configuration**: environment files → ConfigMaps/Secrets
- **Dependencies**: depends_on → initContainers with health checks
- **Scaling**: single containers → replica sets with load balancing

**Key Differences:**
- Kubernetes requires explicit dependency management
- Storage lifecycle is separate from container lifecycle  
- Service discovery uses cluster DNS rather than container linking
- Resource management is mandatory for production workloads
- Configuration management is externalized from container images


## Continuous Integration / Continuous Deployment (CI/CD)

To further align this project with platform engineering practices, I implemented a GitHub Actions workflow that automates Terraform validation and quality checks. This ensures every infrastructure change is reviewed and tested before being applied to the Kubernetes cluster.

### Workflow Highlights
- **Triggers**: Runs on every push to `main` and every pull request.
- **Steps**:
  - Repository checkout
  - Terraform initialization
  - Code formatting check (`terraform fmt`)
  - Syntax validation (`terraform validate`)
  - Static analysis with **TFLint**
  - Execution of `terraform plan` for previewing changes

### Benefits
- Eliminates manual errors when applying Terraform changes
- Provides automated feedback during pull requests
- Enforces best practices with linting and validation
- Sets the foundation for adding `terraform apply` with approvals in future

### Workflow File
Located at:  
`.github/workflows/terraform.yml`

```yaml
name: Terraform CI/CD

on:
  push:
    branches: [ "main" ]
  pull_request:

jobs:
  terraform:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Set up Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: 1.6.6

      - name: Terraform Init
        run: terraform init

      - name: Terraform Format Check
        run: terraform fmt -check

      - name: Terraform Validate
        run: terraform validate

      - name: Run TFLint
        uses: terraform-linters/setup-tflint@v3
        with:
          tflint_version: latest
        run: tflint --init && tflint

      - name: Terraform Plan
        run: terraform plan