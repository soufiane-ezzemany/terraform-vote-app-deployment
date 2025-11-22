# =============================================================================
# Provider Configuration
# =============================================================================
# Configures the Docker provider to connect to the local Docker daemon.
# The Unix socket is the standard way to communicate with Docker on Mac/Linux.

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

