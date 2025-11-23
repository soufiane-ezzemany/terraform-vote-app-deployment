# =============================================================================
# Input Variables
# =============================================================================

variable "namespace" {
  description = "Kubernetes namespace for the voting app"
  type        = string
  default     = "s23ezzem"
}

variable "postgres_password" {
  description = "Password for PostgreSQL database"
  type        = string
  default     = "postgres"
  sensitive   = true
}

variable "node_port_vote" {
  description = "NodePort for the voting service"
  type        = number
  default     = 31000
}

variable "node_port_result" {
  description = "NodePort for the result service"
  type        = number
  default     = 31001
}
