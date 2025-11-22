# =============================================================================
# Input Variables
# =============================================================================
# Variables allow customization of the deployment without modifying the code.
# All variables include validation rules to catch configuration errors early.

variable "nginx_port" {
  description = "External port for Nginx load balancer"
  type        = number
  default     = 8000

  validation {
    condition     = var.nginx_port > 1024 && var.nginx_port < 65535
    error_message = "Port must be between 1024 and 65535 (non-privileged ports)."
  }
}

variable "result_port" {
  description = "External port for Result application"
  type        = number
  default     = 5050

  validation {
    condition     = var.result_port > 1024 && var.result_port < 65535
    error_message = "Port must be between 1024 and 65535 (non-privileged ports)."
  }
}

variable "postgres_password" {
  description = "Password for PostgreSQL database"
  type        = string
  default     = "postgres"
  sensitive   = true # Prevents password from appearing in logs

  validation {
    condition     = length(var.postgres_password) >= 8
    error_message = "Password must be at least 8 characters long for security."
  }
}

