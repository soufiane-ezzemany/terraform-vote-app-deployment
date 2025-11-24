resource "kubernetes_manifest" "pgsql_deployment" {
  manifest = {
    apiVersion = "apps/v1"
    kind       = "Deployment"
    metadata = {
      name      = "pgsql-deplt"
      namespace = var.namespace
      labels = {
        app = "pgsql"
      }
    }
    spec = {
      replicas = 1
      selector = {
        matchLabels = {
          app = "pgsql"
        }
      }
      template = {
        metadata = {
          labels = {
            app = "pgsql"
          }
        }
        spec = {
          initContainers = [
            {
              name    = "dl-hc-scripts"
              image   = "alpine:3.7"
              command = ["/bin/sh", "-c"]
              args    = ["apk add --no-cache git && git clone https://gitlab.imt-atlantique.fr/login-nuage/healthchecks.git /healthchecks/"]
              volumeMounts = [
                {
                  mountPath = "/healthchecks/"
                  name      = "source"
                }
              ]
            }
          ]
          volumes = [
            {
              name     = "source"
              emptyDir = {}
            },
            {
              name     = "db-data"
              emptyDir = {}
            }
          ]
          containers = [
            {
              name  = "postgres-container"
              image = "postgres:15-alpine"
              env = [
                {
                  name  = "POSTGRES_USER"
                  value = "postgres"
                },
                {
                  name  = "POSTGRES_PASSWORD"
                  value = "postgres"
                }
              ]
              ports = [
                {
                  containerPort = 5432
                  name          = "postgres-port"
                }
              ]
              volumeMounts = [
                {
                  mountPath = "/var/lib/postgresql/data"
                  name      = "db-data"
                  subPath   = "data"
                }
              ]
              livenessProbe = {
                exec = {
                  command = ["/healthchecks/postgres.sh"]
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

resource "kubernetes_manifest" "pgsql_service" {
  manifest = {
    apiVersion = "v1"
    kind       = "Service"
    metadata = {
      name      = "db"
      namespace = var.namespace
      labels = {
        app = "pgsql"
      }
    }
    spec = {
      type = "ClusterIP"
      ports = [
        {
          name       = "pgsql-svc-port"
          port       = 5432
          targetPort = "postgres-port"
        }
      ]
      selector = {
        app = "pgsql"
      }
    }
  }
}
