output "vote_url" {
  value       = "http://localhost:${var.nginx_port}"
  description = "URL for the Voting App"
}

output "result_url" {
  value       = "http://localhost:${var.result_port}"
  description = "URL for the Result App"
}
