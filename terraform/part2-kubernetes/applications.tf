# ==============================================================================
# APPLICATION DEPLOYMENTS
# ==============================================================================
# This file contains all Kubernetes deployments and services for the voting app.
# Organized by component for easy maintenance.

# ------------------------------------------------------------------------------
# Vote Application
# ------------------------------------------------------------------------------
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

# ------------------------------------------------------------------------------
# Result Application
# ------------------------------------------------------------------------------
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

# ------------------------------------------------------------------------------
# Worker Application
# ------------------------------------------------------------------------------
module "worker_deployment" {
  source    = "./modules/k8s-manifest"
  file_path = "${local.manifests_path}/worker-deployment.yaml"
  namespace = var.namespace
}

# ------------------------------------------------------------------------------
# PostgreSQL Database
# ------------------------------------------------------------------------------
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

# ------------------------------------------------------------------------------
# Redis (External VM)
# ------------------------------------------------------------------------------
module "redis_endpoints" {
  source = "./modules/k8s-manifest"
  yaml_body = templatefile("${local.manifests_path}/redis-endpoints.yaml", {
    redis_ip = var.redis_vm_ip
  })
  namespace = var.namespace
}

module "redis_service" {
  source    = "./modules/k8s-manifest"
  file_path = "${local.manifests_path}/redis-service.yaml"
  namespace = var.namespace
}

# ------------------------------------------------------------------------------
# Database Seed Job
# ------------------------------------------------------------------------------
module "seed_job" {
  source    = "./modules/k8s-manifest"
  file_path = "${local.manifests_path}/seed-job.yaml"
  namespace = var.namespace
}
