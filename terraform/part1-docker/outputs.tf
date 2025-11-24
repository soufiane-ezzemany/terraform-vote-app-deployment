# =============================================================================
# Outputs
# =============================================================================
# Outputs provide useful information after deployment, such as application URLs.

output "vote_url" {
  value       = "http://localhost:${var.nginx_port}"
  description = "URL for the Voting App (accessed via Nginx load balancer)"
}

output "result_url" {
  value       = "http://localhost:${var.result_port}"
  description = "URL for the Result App (real-time vote results)"
}

