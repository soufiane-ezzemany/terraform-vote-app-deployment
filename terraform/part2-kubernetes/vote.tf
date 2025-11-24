module "vote_deployment" {
  source    = "./modules/k8s-manifest"
  file_path = "${local.manifests_path}/vote-deployment.yaml"
  namespace = var.namespace
}

module "vote_service" {
  source    = "./modules/k8s-manifest"
  file_path = "${local.manifests_path}/vote-service.yaml"
  namespace = var.namespace
}
