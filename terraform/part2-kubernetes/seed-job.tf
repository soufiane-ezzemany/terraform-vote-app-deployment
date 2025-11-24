resource "kubernetes_manifest" "seed_job" {
  manifest = {
    apiVersion = "batch/v1"
    kind       = "Job"
    metadata = {
      name      = "seed-job"
      namespace = var.namespace
      labels = {
        app = "seed-job"
      }
    }
    spec = {
      template = {
        spec = {
          containers = [
            {
              name  = "seed-job"
              image = "eloip13009/voting-fila3:seed-data"
              env = [
                {
                  name  = "TARGET_HOST"
                  value = "vote"
                },
                {
                  name  = "TARGET_PORT"
                  value = "5000"
                }
              ]
            }
          ]
          restartPolicy = "Never"
        }
      }
    }
  }

  depends_on = [
    kubernetes_manifest.vote_deployment,
    kubernetes_manifest.vote_service
  ]
}
