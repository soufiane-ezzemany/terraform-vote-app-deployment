# =============================================================================
# Outputs
# =============================================================================

output "vote_url" {
  description = "URL for the voting application"
  value       = "http://localhost:${var.node_port_vote}"
}

output "result_url" {
  description = "URL for the result application"
  value       = "http://localhost:${var.node_port_result}"
}

output "namespace" {
  description = "Kubernetes namespace"
  value       = kubernetes_namespace.voting_app.metadata[0].name
}
