module "pgsql_deployment" {
  source    = "./modules/k8s-manifest"
  namespace = var.namespace
  yaml_body = replace(
    file("${local.manifests_path}/pgsql-deployment.yaml"),
    "persistentVolumeClaim:\n          claimName: db-data-claim",
    "emptyDir: {}"
  )
}

module "pgsql_service" {
  source    = "./modules/k8s-manifest"
  file_path = "${local.manifests_path}/pgsql-service.yaml"
  namespace = var.namespace
}
