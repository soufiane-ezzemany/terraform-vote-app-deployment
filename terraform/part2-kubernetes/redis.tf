module "redis_deployment" {
  source    = "./modules/k8s-manifest"
  file_path = "${local.manifests_path}/redis-deployment.yaml"
  namespace = var.namespace
}

module "redis_service" {
  source    = "./modules/k8s-manifest"
  file_path = "${local.manifests_path}/redis-service.yaml"
  namespace = var.namespace
}
