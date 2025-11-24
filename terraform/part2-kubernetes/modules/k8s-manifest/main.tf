locals {
  # Use yaml_body if provided, otherwise read from file_path
  manifest_content = var.yaml_body != null ? var.yaml_body : file(var.file_path)
  decoded_manifest = yamldecode(local.manifest_content)
}

resource "kubernetes_manifest" "this" {
  manifest = merge(
    local.decoded_manifest,
    {
      metadata = merge(
        local.decoded_manifest.metadata,
        { namespace = var.namespace }
      )
    }
  )
}

output "object" {
  value = kubernetes_manifest.this.object
}
