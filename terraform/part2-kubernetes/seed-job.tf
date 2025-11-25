module "seed_job" {
  source    = "./modules/k8s-manifest"
  file_path = "${local.manifests_path}/seed-job.yaml"
  namespace = var.namespace

  # Ensure seed job runs after vote service is ready
  depends_on = [module.vote_service, module.vote_deployment]
}
