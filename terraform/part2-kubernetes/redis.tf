resource "kubernetes_manifest" "redis_deployment" {
  manifest = {
    apiVersion = "apps/v1"
    kind       = "Deployment"
    metadata = {
      name      = "redis-deplt"
      namespace = var.namespace
      labels = {
        app = "redis"
      }
    }
    spec = {
      replicas = 1
      selector = {
        matchLabels = {
          app = "redis"
        }
      }
      template = {
        metadata = {
          labels = {
            app = "redis"
          }
        }
        spec = {
          containers = [
            {
              name  = "redis-container"
              image = "redis:alpine"
              ports = [
                {
                  containerPort = 6379
                  name          = "redis-port"
                }
              ]
              livenessProbe = {
                exec = {
                  command = ["/healthchecks/redis.sh"]
                }
                periodSeconds = 15
              }
            }
          ]
        }
      }
    }
  }
}

resource "kubernetes_manifest" "redis_service" {
  manifest = {
    apiVersion = "v1"
    kind       = "Service"
    metadata = {
      name      = "redis"
      namespace = var.namespace
      labels = {
        app = "redis"
      }
    }
    spec = {
      type = "NodePort"
      ports = [
        {
          name       = "redis-svc-port"
          port       = 6379
          targetPort = 6379
          protocol   = "TCP"
        }
      ]
      selector = {
        app = "redis"
      }
    }
  }
}
