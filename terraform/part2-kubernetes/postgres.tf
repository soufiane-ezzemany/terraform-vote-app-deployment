resource "kubernetes_manifest" "pgsql_deployment" {
  manifest = merge(
    yamldecode(
      replace(
        file("${local.manifests_path}/pgsql-deployment.yaml"),
        "persistentVolumeClaim:\n          claimName: db-data-claim",
        "emptyDir: {}"
      )
    ),
    {
      metadata = merge(
        yamldecode(file("${local.manifests_path}/pgsql-deployment.yaml")).metadata,
        { namespace = var.namespace }
      )
    }
  )
}

resource "kubernetes_manifest" "pgsql_service" {
  manifest = merge(
    yamldecode(file("${local.manifests_path}/pgsql-service.yaml")),
    {
      metadata = merge(
        yamldecode(file("${local.manifests_path}/pgsql-service.yaml")).metadata,
        { namespace = var.namespace }
      )
    }
  )
}
