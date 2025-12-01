variable "vm_name" {
  description = "Name of the VM"
  type        = string
  default     = "vm-s23ezzem"
}

variable "vm_ip" {
  description = "IP address of the VM"
  type        = string
  default     = "10.144.208.105"
}

variable "ssh_key_path" {
  description = "Path to the public SSH key"
  type        = string
  default     = "/Users/soufiane/.ssh/id_rsa.pub"
}

variable "ciuser" {
  description = "Cloud-init user"
  type        = string
  default     = "s23ezzem"
}

variable "connection_user" {
  description = "User for SSH connection"
  type        = string
  default     = "s23ezzem"
}

