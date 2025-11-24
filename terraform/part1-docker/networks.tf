# =============================================================================
# Docker Networks
# =============================================================================
# Creates isolated networks for service communication 

# Front-tier network: For public-facing services
# Services: nginx, vote, result
resource "docker_network" "front_tier" {
  name = "front-tier"
}

# Back-tier network: For backend services and databases
# Services: redis, postgres, vote, result, worker
resource "docker_network" "back_tier" {
  name = "back-tier"
}

