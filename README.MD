# Kubernetes Data Platform

This project migrates and extends the [Lambda Data Platform](https://github.com/pyvel26/Lambda-Inspired-Platform) from Docker Compose to Kubernetes, demonstrating cloud-native migration patterns and distributed systems orchestration. The platform maintains the same Lambda architecture with real-time streaming and scheduled batch processing, now deployed with enterprise-grade container orchestration.

---

## Architecture Evolution

**Migration Path**: Docker Compose → Kubernetes + Terraform IaC

The core Lambda architecture remains unchanged while gaining enterprise capabilities:
- **Horizontal scaling** with replica sets
- **Service discovery** with DNS-based networking  
- **Persistent storage** with PV/PVC management
- **Infrastructure as Code** with Terraform
- **Dependency orchestration** with initContainers
- **Resource management** with requests/limits

---

## Platform Components

### Real-time Stream Processing:
- **lambda-producer-stream** (3 replicas): Generates live transaction data and streams to Kafka
- **kafka-service**: Distributed message broker with ZooKeeper coordination
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

## Kubernetes Architecture

### Networking:
- **Services**: ClusterIP for internal communication, NodePort for external access
- **DNS Discovery**: Pods communicate via service names (kafka-service:9092)
- **Load Balancing**: Automatic traffic distribution across replicas

### Storage:
- **Persistent Volumes**: Kafka and Postgres data persistence
- **Storage Classes**: Dynamic volume provisioning
- **StatefulSets**: Ordered deployment for stateful services

### Orchestration:
- **Deployments**: Replica management for stateless services
- **Jobs/CronJobs**: Batch processing automation
- **InitContainers**: Dependency management and startup ordering
- **ConfigMaps/Secrets**: Environment configuration management

---

## Infrastructure as Code

**Technology Stack:**
- **Kubernetes**: Container orchestration
- **Terraform**: Infrastructure provisioning and management
- **Minikube**: Local development cluster
- **Docker**: Container runtime and image management

**Resource Management:**
- **Resource Requests**: Guaranteed resource allocation
- **Resource Limits**: Maximum resource constraints  
- **Horizontal Pod Autoscaling**: Automatic scaling based on CPU/memory
- **Namespace Isolation**: Environment separation (dev namespace)

---

## Key Technical Challenges Solved

### 1. **Dependency Management**
- **Problem**: Services starting before dependencies (Kafka before ZooKeeper)
- **Solution**: InitContainers with health checks using `nc -zv` port testing

### 2. **Storage Persistence** 
- **Problem**: Data loss on pod restarts, corrupted volume states
- **Solution**: Proper PV/PVC lifecycle management with storage class configuration

### 3. **Service Discovery**
- **Problem**: Hardcoded localhost connections breaking in distributed environment
- **Solution**: Kubernetes DNS with service-based addressing (kafka-service:9092)

### 4. **Configuration Management**
- **Problem**: Environment-specific secrets and configuration drift
- **Solution**: Kubernetes Secrets with base64 encoding and envFrom injection

### 5. **Resource Allocation**
- **Problem**: Pod resource competition and cluster resource exhaustion
- **Solution**: Resource requests/limits with monitoring via metrics-server

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
│   ├── deployments/         # Application deployments
│   │   ├── consumer-stream.yaml
│   │   ├── kafka.yaml
│   │   ├── pgadmin.yaml
│   │   ├── postgres.yaml
│   │   ├── producer-stream.yaml
│   │   └── zookeeper.yaml
│   ├── services/           # Kubernetes services
│   │   ├── kafka.yaml
│   │   ├── pgadmin-service.yaml
│   │   ├── postgres.yaml
│   │   └── zoo-service.yaml
│   ├── jobs/               # Batch processing jobs
│   │   ├── cron-batch.yaml
│   │   └── db-setup-job.yaml
│   ├── secrets/            # Configuration secrets
│   │   └── database-secrets.yaml
│   ├── volumes/            # PVC definitions
│   │   ├── kafka-pvc.yaml
│   │   └── postgres-pvc.yaml
│   └── namespace.yaml      # Kubernetes namespace
├── terraform/              # Infrastructure as Code
│   ├── batch.tf           # Batch processing resources
│   ├── core.tf            # Core infrastructure
│   ├── foundation.tf      # Base cluster setup
│   ├── job_admin.tf       # Job administration
│   ├── providers.tf       # Terraform providers
│   ├── stream.tf          # Streaming components
│   └── terraform.tfstate  # State management
└── README.md              # Project documentation
```

---

## Technologies

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
- Service mesh networking concepts
- Stateful vs stateless service design
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