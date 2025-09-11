# 1) Namespace: creates "dev"
resource "kubernetes_manifest" "ns" {
  manifest = yamldecode(file("${path.module}/../kubernetes/namespace.yaml"))
  # The YAML itself should set metadata.name: dev
}

# 2) Storage: PVCs must exist before DB/broker pods mount them.
resource "kubernetes_manifest" "postgres_pvc" {
  manifest   = yamldecode(file("${path.module}/../kubernetes/volumes/postgres-pvc.yaml"))
  depends_on = [kubernetes_manifest.ns]
}

resource "kubernetes_manifest" "kafka_pvc" {
  manifest   = yamldecode(file("${path.module}/../kubernetes/volumes/kafka-pvc.yaml"))
  depends_on = [kubernetes_manifest.ns]
}

# 3) Secret: DB credentials/config used by Postgres/pgAdmin later.
resource "kubernetes_manifest" "db_secret" {
  manifest   = yamldecode(file("${path.module}/../kubernetes/secrets/database-secrets.yaml"))
  depends_on = [kubernetes_manifest.ns]
}

# 4) Services: stable DNS names other workloads will call later.
resource "kubernetes_manifest" "postgres_svc" {
  manifest   = yamldecode(file("${path.module}/../kubernetes/services/postgres.yaml"))
  depends_on = [kubernetes_manifest.ns]
}

resource "kubernetes_manifest" "kafka_svc" {
  manifest   = yamldecode(file("${path.module}/../kubernetes/services/kafka.yaml"))
  depends_on = [kubernetes_manifest.ns]
}

resource "kubernetes_manifest" "pgadmin_svc" {
  manifest   = yamldecode(file("${path.module}/../kubernetes/services/pgadmin-service.yaml"))
  depends_on = [kubernetes_manifest.ns]
}

resource "kubernetes_manifest" "zoo_svc" {
  manifest   = yamldecode(file("${path.module}/../kubernetes/services/zoo-service.yaml"))
  depends_on = [kubernetes_manifest.ns]
}

