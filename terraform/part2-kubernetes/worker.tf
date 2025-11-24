module "worker_deployment" {
  source    = "./modules/k8s-manifest"
  file_path = "${local.manifests_path}/worker-deployment.yaml"
  namespace = var.namespace
}
