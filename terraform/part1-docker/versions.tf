# =============================================================================
# Terraform and Provider Version Constraints
# =============================================================================
# Version constraints ensure reproducible deployments across different
# environments and prevent breaking changes from newer provider versions.

terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.2"
    }
  }
  required_version = ">= 1.0"
}
