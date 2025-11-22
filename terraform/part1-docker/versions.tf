# =============================================================================
# Terraform and Provider Version Constraints
# =============================================================================
# Version constraints ensure reproducible deployments across different
# environments and prevent breaking changes from newer provider versions.

terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1" # Allow patch updates (3.0.x) but not minor/major
    }
  }
  required_version = ">= 1.0" # Minimum Terraform version required
}

