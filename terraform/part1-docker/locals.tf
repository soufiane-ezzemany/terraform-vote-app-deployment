# =============================================================================
# Locals - Centralized Configuration Values
# =============================================================================
# This file defines local values that are reused across multiple resources.
# Using locals follows the DRY (Don't Repeat Yourself) principle and makes
# the configuration easier to maintain.

locals {
  # Project paths - centralized to avoid repetition
  project_root      = "${path.cwd}/../.."
  services_path     = "${local.project_root}/voting-services"
  healthchecks_path = "${local.project_root}/healthchecks"

  # Image configuration
  image_tag = "latest"

  # Common labels for resource tagging
  common_labels = {
    project     = "voting-app"
    environment = "development"
    managed_by  = "terraform"
    part        = "1-docker"
  }

  # Health check configurations
  redis_healthcheck = {
    test     = ["CMD", "sh", "/healthchecks/redis.sh"]
    interval = "5s"
  }

  postgres_healthcheck = {
    test     = ["CMD", "sh", "/healthchecks/postgres.sh"]
    interval = "5s"
  }

  vote_healthcheck = {
    test         = ["CMD", "curl", "-f", "http://localhost:5000"]
    interval     = "15s"
    timeout      = "5s"
    retries      = 2
    start_period = "5s"
  }
}
