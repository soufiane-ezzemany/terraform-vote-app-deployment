# =============================================================================
# Kubernetes Provider Configuration
# =============================================================================

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "minikube" # Updated for local Minikube testing
}
