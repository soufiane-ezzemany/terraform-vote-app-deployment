module "result_deployment" {
  source    = "./modules/k8s-manifest"
  file_path = "${local.manifests_path}/result-deployment.yaml"
  namespace = var.namespace
}

module "result_service" {
  source    = "./modules/k8s-manifest"
  file_path = "${local.manifests_path}/result-service.yaml"
  namespace = var.namespace
}
