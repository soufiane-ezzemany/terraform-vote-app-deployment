# =============================================================================
# Terraform and Provider Version Constraints
# =============================================================================

terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.24.0"
    }
  }
  required_version = ">= 1.0"
}
