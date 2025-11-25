output "namespace" {
  description = "Kubernetes namespace where resources are deployed"
  value       = var.namespace
}

output "vote_url" {
  description = "URL to access the Vote service"
  value       = "http://10.144.208.131:${module.vote_service.object.spec.ports[0].nodePort}" # ip for cluster 52, change it to 102 instead of 131 to get 51
}

output "result_url" {
  description = "URL to access the Result service"
  value       = "http://10.144.208.131:${module.result_service.object.spec.ports[0].nodePort}" # ip for cluster 52
}
