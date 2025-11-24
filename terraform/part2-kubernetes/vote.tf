resource "kubernetes_manifest" "vote_deployment" {
  manifest = merge(
    yamldecode(file("${local.manifests_path}/vote-deployment.yaml")),
    {
      metadata = merge(
        yamldecode(file("${local.manifests_path}/vote-deployment.yaml")).metadata,
        { namespace = var.namespace }
      )
    }
  )
}

resource "kubernetes_manifest" "vote_service" {
  manifest = merge(
    yamldecode(file("${local.manifests_path}/vote-service.yaml")),
    {
      metadata = merge(
        yamldecode(file("${local.manifests_path}/vote-service.yaml")).metadata,
        { namespace = var.namespace }
      )
    }
  )
}
