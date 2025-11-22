# =============================================================================
# Docker Volumes
# =============================================================================
# Persistent storage for stateful services.

# PostgreSQL data volume - stores database files
resource "docker_volume" "db_data" {
  name = "db-data"
}
