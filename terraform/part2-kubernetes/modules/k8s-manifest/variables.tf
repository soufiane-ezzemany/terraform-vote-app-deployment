variable "file_path" {
  description = "Path to the YAML manifest file"
  type        = string
  default     = null
}

variable "yaml_body" {
  description = "Raw YAML content (overrides file_path)"
  type        = string
  default     = null
}

variable "namespace" {
  description = "Kubernetes namespace to inject"
  type        = string
}
