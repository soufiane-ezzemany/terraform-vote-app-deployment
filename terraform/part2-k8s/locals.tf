# =============================================================================
# Local Values
# =============================================================================

locals {
  common_labels = {
    app         = "voting-app"
    environment = "development"
    managed_by  = "terraform"
    part        = "2-k8s"
  }
}