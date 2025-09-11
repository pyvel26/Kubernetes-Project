# db-setup Job
resource "kubernetes_manifest" "db_setup_job" {
  manifest = yamldecode(file("${path.module}/../kubernetes/jobs/db-setup-job.yaml"))
  depends_on = [
    kubernetes_manifest.ns,
    kubernetes_manifest.postgres,
  ]
}

# pgAdmin Deployment
resource "kubernetes_manifest" "pgadmin" {
  manifest = yamldecode(file("${path.module}/../kubernetes/deployments/pgadmin.yaml"))
  depends_on = [
    kubernetes_manifest.ns,
    kubernetes_manifest.db_secret,
    kubernetes_manifest.postgres_svc,
  ]
}
