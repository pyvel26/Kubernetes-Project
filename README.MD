# Kubernetes Data Platform (with CI/CD)

This project extends my **Lambda-Inspired Data Platform** by migrating from Docker Compose to **Kubernetes** and managing infrastructure with **Terraform**. It demonstrates how to modernize a data platform with container orchestration, Infrastructure as Code, and CI/CD best practices.  

---

## Highlights

- **Architecture Migration**: Docker Compose → Kubernetes + Terraform  
- **Streaming + Batch**: Real-time (Kafka) + scheduled batch (CronJob) pipelines  
- **Infrastructure as Code**: Kubernetes resources managed via Terraform  
- **CI/CD**: GitHub Actions workflow validates Terraform, enforces formatting, runs TFLint, and generates a safe plan before changes are applied.  

---

## Components

- **PostgreSQL** with persistent volumes  
- **Kafka + ZooKeeper** for real-time streaming  
- **Producers & Consumers** (Python) for event data  
- **CSV Batch Processor + CronJob** for nightly batch ingestion  
- **pgAdmin** for DB monitoring  
- **db-setup Job** for schema initialization  

---

## Key Technical Challenges Solved

- **Dependency Management**: Used initContainers + readinessProbes to ensure services wait for dependencies (Kafka before ZooKeeper, DB setup after Postgres).  
- **Persistent Storage**: PV/PVC setup for Kafka & Postgres to survive pod restarts.  
- **Secrets**: Configured credentials via Kubernetes Secrets (base64-encoded).  
- **CI/CD**: Automated checks with GitHub Actions to ensure reliable infrastructure delivery.  

---

## Data Flow

**Streaming** → Producer → Kafka → Consumer → PostgreSQL  
**Batch** → CronJob → CSV Batch Processor → PostgreSQL  

---

## Tech Stack

- **Kubernetes, Terraform, Minikube, Docker**  
- **Apache Kafka, ZooKeeper, PostgreSQL, pgAdmin**  
- **Python 3.11** (producers/consumers, batch jobs)  
- **GitHub Actions** (CI/CD pipeline with Terraform + TFLint)  

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
