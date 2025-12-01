output "namespace" {
  description = "Kubernetes namespace where resources are deployed"
  value       = var.namespace
}

output "vote_url" {
  description = "URL to access the Vote service"
  value       = "http://${var.node_ip}:${module.vote_service.object.spec.ports[0].nodePort}"
}

output "result_url" {
  description = "URL to access the Result service"
  value       = "http://${var.node_ip}:${module.result_service.object.spec.ports[0].nodePort}"
}
