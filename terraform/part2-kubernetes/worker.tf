resource "kubernetes_manifest" "worker_deployment" {
  manifest = merge(
    yamldecode(file("${local.manifests_path}/worker-deployment.yaml")),
    {
      metadata = merge(
        yamldecode(file("${local.manifests_path}/worker-deployment.yaml")).metadata,
        { namespace = var.namespace }
      )
    }
  )
}
