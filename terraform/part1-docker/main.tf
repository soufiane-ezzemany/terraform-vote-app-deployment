# =============================================================================
# Docker Images
# =============================================================================
# This section defines all Docker images used in the application.

# Redis
resource "docker_image" "redis" {
  name         = "redis:alpine"
  force_remove = true
}

# PostgreSQL
resource "docker_image" "postgres" {
  name         = "postgres:15-alpine"
  force_remove = true
}

# Vote
resource "docker_image" "vote" {
  name         = "vote:${local.image_tag}"
  force_remove = true
  build {
    context    = "${local.services_path}/vote"
    dockerfile = "Dockerfile"
    no_cache   = false
  }
}

# Result
resource "docker_image" "result" {
  name         = "result:${local.image_tag}"
  force_remove = true
  build {
    context    = "${local.services_path}/result"
    dockerfile = "Dockerfile"
    no_cache   = false
  }
}

# Worker
resource "docker_image" "worker" {
  name         = "worker:${local.image_tag}"
  force_remove = true
  build {
    context    = "${local.services_path}/worker"
    dockerfile = "Dockerfile"
    no_cache   = false
  }
}

# Nginx (load balancer)
resource "docker_image" "nginx" {
  name         = "nginx-vote:${local.image_tag}"
  force_remove = true
  build {
    context    = "${local.services_path}/nginx"
    dockerfile = "Dockerfile"
    no_cache   = false
  }
}

# Seed
resource "docker_image" "seed" {
  name         = "seed:${local.image_tag}"
  force_remove = true
  build {
    context    = "${local.services_path}/seed-data"
    dockerfile = "Dockerfile"
    no_cache   = false
  }
}

# =============================================================================
# Docker Containers
# =============================================================================
# This section defines all running containers for the application.

# Redis
resource "docker_container" "redis" {
  name  = "redis"
  image = docker_image.redis.image_id
  networks_advanced {
    name = docker_network.back_tier.name
  }
  healthcheck {
    test     = local.redis_healthcheck.test
    interval = local.redis_healthcheck.interval
  }
  volumes {
    host_path      = local.healthchecks_path
    container_path = "/healthchecks"
  }
}

# PostgreSQL Database
resource "docker_container" "db" {
  name  = "db"
  image = docker_image.postgres.image_id
  networks_advanced {
    name = docker_network.back_tier.name
  }
  env = [
    "POSTGRES_PASSWORD=${var.postgres_password}"
  ]
  healthcheck {
    test     = local.postgres_healthcheck.test
    interval = local.postgres_healthcheck.interval
  }
  volumes {
    volume_name    = docker_volume.db_data.name
    container_path = "/var/lib/postgresql/data"
  }
  volumes {
    host_path      = local.healthchecks_path
    container_path = "/healthchecks"
  }
}

# Vote Instances (x2)
resource "docker_container" "vote" {
  count = 2
  name  = "vote${count.index + 1}"
  image = docker_image.vote.image_id

  networks_advanced {
    name = docker_network.front_tier.name
  }
  networks_advanced {
    name = docker_network.back_tier.name
  }

  healthcheck {
    test         = local.vote_healthcheck.test
    interval     = local.vote_healthcheck.interval
    timeout      = local.vote_healthcheck.timeout
    retries      = local.vote_healthcheck.retries
    start_period = local.vote_healthcheck.start_period
  }

  depends_on = [
    docker_container.redis
  ]
}

# Result
resource "docker_container" "result" {
  name  = "result"
  image = docker_image.result.image_id
  networks_advanced {
    name = docker_network.front_tier.name
  }
  networks_advanced {
    name = docker_network.back_tier.name
  }
  ports {
    internal = 80
    external = var.result_port
  }
  depends_on = [
    docker_container.db
  ]
}

# Worker
resource "docker_container" "worker" {
  name  = "worker"
  image = docker_image.worker.image_id
  networks_advanced {
    name = docker_network.back_tier.name
  }
  depends_on = [
    docker_container.redis,
    docker_container.db
  ]
}

# Nginx Load Balancer
resource "docker_container" "nginx" {
  name  = "nginx"
  image = docker_image.nginx.image_id
  networks_advanced {
    name = docker_network.front_tier.name
  }
  ports {
    internal = 8000
    external = var.nginx_port
  }
  depends_on = [
    docker_container.vote
  ]
}

# Seed
resource "docker_container" "seed" {
  name  = "seed"
  image = docker_image.seed.image_id
  networks_advanced {
    name = docker_network.front_tier.name
  }
  env = [
    "TARGET_HOST=nginx",
    "TARGET_PORT=8000"
  ]
  depends_on = [
    docker_container.nginx
  ]
  restart = "no"
}
