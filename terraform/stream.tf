# Producer Deployment
resource "kubernetes_manifest" "producer" {
  manifest = yamldecode(file("${path.module}/../kubernetes/deployments/producer-stream.yaml"))

  depends_on = [
    kubernetes_manifest.ns,
    kubernetes_manifest.kafka,
  ]
}

# Consumer Deployment
resource "kubernetes_manifest" "consumer" {
  manifest = yamldecode(file("${path.module}/../kubernetes/deployments/consumer-stream.yaml"))

  depends_on = [
    kubernetes_manifest.ns,
    kubernetes_manifest.kafka,
    kubernetes_manifest.postgres,
  ]
}


