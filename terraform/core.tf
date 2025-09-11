# Postgres Deployment
resource "kubernetes_manifest" "postgres" {
  manifest = yamldecode(file("${path.module}/../kubernetes/deployments/postgres.yaml"))

  depends_on = [
    kubernetes_manifest.ns,
    kubernetes_manifest.postgres_pvc,
    kubernetes_manifest.db_secret,
    kubernetes_manifest.postgres_svc,
  ]
}

# Kafka Deployment
resource "kubernetes_manifest" "kafka" {
  manifest = yamldecode(file("${path.module}/../kubernetes/deployments/kafka.yaml"))

  depends_on = [
    kubernetes_manifest.ns,
    kubernetes_manifest.kafka_pvc,
    kubernetes_manifest.kafka_svc,
    kubernetes_manifest.zoo_svc
  ]
}

# Zookeeper Deployment
resource "kubernetes_manifest" "zookeeper" {
  manifest = yamldecode(file("${path.module}/../kubernetes/deployments/zookeeper.yaml"))

  depends_on = [
    kubernetes_manifest.ns,
    kubernetes_manifest.zoo_svc,
  ]
}