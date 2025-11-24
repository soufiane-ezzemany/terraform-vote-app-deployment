resource "kubernetes_manifest" "result_deployment" {
  manifest = merge(
    yamldecode(file("${local.manifests_path}/result-deployment.yaml")),
    {
      metadata = merge(
        yamldecode(file("${local.manifests_path}/result-deployment.yaml")).metadata,
        { namespace = var.namespace }
      )
    }
  )
}

resource "kubernetes_manifest" "result_service" {
  manifest = merge(
    yamldecode(file("${local.manifests_path}/result-service.yaml")),
    {
      metadata = merge(
        yamldecode(file("${local.manifests_path}/result-service.yaml")).metadata,
        { namespace = var.namespace }
      )
    }
  )
}
