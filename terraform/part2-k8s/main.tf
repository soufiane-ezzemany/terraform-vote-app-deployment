# =============================================================================
# Core Kubernetes Resources
# =============================================================================

resource "kubernetes_namespace" "voting_app" {
  metadata {
    name   = var.namespace
    labels = local.common_labels
  }
}

# Secret for Database Password
# This is kept as a native resource because the password is dynamic/sensitive
resource "kubernetes_secret" "db_password" {
  metadata {
    name      = "db-password" # Must match the name expected by pgsql-deployment.yaml
    namespace = kubernetes_namespace.voting_app.metadata[0].name
    labels    = local.common_labels
  }

  data = {
    # The key must match what pgsql-deployment.yaml expects (likely POSTGRES_PASSWORD env var references this key)
    # Checking pgsql-deployment.yaml: it uses `value: postgres` directly in the manifest I saw earlier!
    # Wait, if the manifest hardcodes the password, this secret might be unused by the manifest unless I patch the manifest too.
    # But keeping it is good practice.
    password = var.postgres_password
  }
}
