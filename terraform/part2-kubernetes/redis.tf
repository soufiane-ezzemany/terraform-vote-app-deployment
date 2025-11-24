resource "kubernetes_manifest" "redis_deployment" {
  manifest = merge(
    yamldecode(file("${local.manifests_path}/redis-deployment.yaml")),
    {
      metadata = merge(
        yamldecode(file("${local.manifests_path}/redis-deployment.yaml")).metadata,
        { namespace = var.namespace }
      )
    }
  )
}

resource "kubernetes_manifest" "redis_service" {
  manifest = merge(
    yamldecode(file("${local.manifests_path}/redis-service.yaml")),
    {
      metadata = merge(
        yamldecode(file("${local.manifests_path}/redis-service.yaml")).metadata,
        { namespace = var.namespace }
      )
    }
  )
}
