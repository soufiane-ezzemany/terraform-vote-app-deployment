variable "nginx_port" {
  description = "Port for Nginx"
  type        = number
  default     = 8000
}

variable "result_port" {
  description = "Port for Result app"
  type        = number
  default     = 5050
}

variable "postgres_password" {
  description = "Password for Postgres"
  type        = string
  default     = "postgres"
}
