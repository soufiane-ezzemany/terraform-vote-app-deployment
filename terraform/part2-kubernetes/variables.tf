variable "namespace" {
  description = "Kubernetes namespace for the voting app"
  type        = string
  default     = "q23legof"
}

variable "kubeconfig_path" {
  description = "Path to kubeconfig file"
  type        = string
  default     = "./config/kubeconfig"
}
