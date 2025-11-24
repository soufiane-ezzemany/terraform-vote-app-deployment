variable "namespace" {
  description = "Kubernetes namespace for the voting application"
  type        = string
  default     = "s23ezzem"
}

variable "kubeconfig_path" {
  description = "Path to the kubeconfig file"
  type        = string
  default     = "./config/kubeconfig"
}
