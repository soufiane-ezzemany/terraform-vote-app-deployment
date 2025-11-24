resource "kubernetes_manifest" "seed_job" {
  manifest = merge(
    yamldecode(file("${local.manifests_path}/seed-job.yaml")),
    {
      metadata = merge(
        yamldecode(file("${local.manifests_path}/seed-job.yaml")).metadata,
        { namespace = var.namespace }
      )
    }
  )

  # Ensure seed job runs after vote service is ready
  depends_on = [kubernetes_manifest.vote_service]
}
