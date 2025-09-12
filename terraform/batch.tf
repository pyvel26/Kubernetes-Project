# CronJob for nightly batch
resource "kubernetes_manifest" "csv_cron" {
  manifest = yamldecode(file("${path.module}/../kubernetes/jobs/cron-batch-job.yaml"))

  depends_on = [
    kubernetes_manifest.ns,
    kubernetes_manifest.postgres
  ]
}