# =============================================================================
# Kubernetes Manifests
# =============================================================================

locals {
  manifests = [
    "db-data-pvc.yaml",
    "pgsql-deployment.yaml",
    "pgsql-service.yaml",
    "redis-deployment.yaml",
    "redis-service.yaml",
    "result-deployment.yaml",
    "result-service.yaml",
    "vote-deployment.yaml",
    "vote-service.yaml",
    "worker-deployment.yaml",
    # "vote-hpa.yaml", # Commented out in source
    "seed-job.yaml"
  ]
}

resource "kubernetes_manifest" "app" {
  for_each = toset(local.manifests)

  manifest = merge(
    yamldecode(file("${path.module}/../../k8s-manifests/${each.value}")),
    {
      metadata = merge(
        yamldecode(file("${path.module}/../../k8s-manifests/${each.value}")).metadata,
        {
          namespace = var.namespace
        }
      )
    },
    # Patch NodePorts for specific services to match variables
    each.value == "vote-service.yaml" ? {
      spec = merge(
        yamldecode(file("${path.module}/../../k8s-manifests/${each.value}")).spec,
        {
          ports = [
            merge(
              yamldecode(file("${path.module}/../../k8s-manifests/${each.value}")).spec.ports[0],
              {
                nodePort = var.node_port_vote
              }
            )
          ]
        }
      )
    } : {},
    each.value == "result-service.yaml" ? {
      spec = merge(
        yamldecode(file("${path.module}/../../k8s-manifests/${each.value}")).spec,
        {
          ports = [
            merge(
              yamldecode(file("${path.module}/../../k8s-manifests/${each.value}")).spec.ports[0],
              {
                nodePort = var.node_port_result
              }
            )
          ]
        }
      )
    } : {}
  )

  depends_on = [
    kubernetes_namespace.voting_app,
    kubernetes_secret.db_password
  ]
}
