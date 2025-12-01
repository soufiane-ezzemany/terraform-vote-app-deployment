variable "namespace" {
  description = "Kubernetes namespace for the voting app"
  type        = string
  default     = "s23ezzem"
}

variable "kubeconfig_path" {
  description = "Path to kubeconfig file"
  type        = string
  default     = "./config/kubeconfig"
}

variable "node_ip" {
  description = "IP address of the Kubernetes node"
  type        = string
  default     = "10.144.208.102"
}

variable "redis_vm_ip" {
  description = "IP address of the Redis VM"
  type        = string
  default     = "10.144.208.105"
}
