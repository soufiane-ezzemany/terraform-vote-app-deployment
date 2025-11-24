resource "kubernetes_manifest" "vote_deployment" {
  manifest = {
    apiVersion = "apps/v1"
    kind       = "Deployment"
    metadata = {
      name      = "vote-deplt"
      namespace = var.namespace
      labels = {
        app = "vote"
      }
    }
    spec = {
      replicas = 1
      selector = {
        matchLabels = {
          app = "vote"
        }
      }
      template = {
        metadata = {
          labels = {
            app = "vote"
          }
        }
        spec = {
          containers = [
            {
              name  = "vote-container"
              image = "eloip13009/voting-fila3:vote"
              ports = [
                {
                  containerPort = 5000
                  name          = "vote-port"
                }
              ]
              livenessProbe = {
                httpGet = {
                  path = "/"
                  port = "vote-port"
                }
                periodSeconds       = 15
                timeoutSeconds      = 5
                failureThreshold    = 2
                initialDelaySeconds = 5
              }
              resources = {
                requests = {
                  cpu = "20m"
                }
              }
            }
          ]
        }
      }
    }
  }
}

resource "kubernetes_manifest" "vote_service" {
  manifest = {
    apiVersion = "v1"
    kind       = "Service"
    metadata = {
      name      = "vote"
      namespace = var.namespace
      labels = {
        app = "vote"
      }
    }
    spec = {
      type = "NodePort"
      ports = [
        {
          name       = "vote-svc-port"
          port       = 5000
          targetPort = "vote-port"
        }
      ]
      selector = {
        app = "vote"
      }
    }
  }
}
