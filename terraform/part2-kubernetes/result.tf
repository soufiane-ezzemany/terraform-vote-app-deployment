resource "kubernetes_manifest" "result_deployment" {
  manifest = {
    apiVersion = "apps/v1"
    kind       = "Deployment"
    metadata = {
      name      = "result-deplt"
      namespace = var.namespace
      labels = {
        app = "result"
      }
    }
    spec = {
      replicas = 1
      selector = {
        matchLabels = {
          app = "result"
        }
      }
      template = {
        metadata = {
          labels = {
            app = "result"
          }
        }
        spec = {
          containers = [
            {
              name  = "result-container"
              image = "eloip13009/voting-fila3:result"
              ports = [
                {
                  containerPort = 80
                  name          = "result-port"
                }
              ]
              livenessProbe = {
                httpGet = {
                  path = "/"
                  port = "result-port"
                }
                periodSeconds       = 15
                timeoutSeconds      = 5
                failureThreshold    = 2
                initialDelaySeconds = 5
              }
            }
          ]
        }
      }
    }
  }
}

resource "kubernetes_manifest" "result_service" {
  manifest = {
    apiVersion = "v1"
    kind       = "Service"
    metadata = {
      name      = "result"
      namespace = var.namespace
      labels = {
        app = "result"
      }
    }
    spec = {
      type = "NodePort"
      ports = [
        {
          name       = "result-svc-port"
          port       = 5050
          targetPort = "result-port"
        }
      ]
      selector = {
        app = "result"
      }
    }
  }
}
