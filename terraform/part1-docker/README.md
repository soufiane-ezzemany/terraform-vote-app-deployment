# Part 1: Docker Deployment with Terraform

This directory contains Terraform configuration for deploying the Voting App locally using Docker.

## Prerequisites

- **Terraform** >= 1.0
- **Docker Desktop** running on your machine
- **Git** for version control

## Architecture

The application consists of 8 containers across 2 networks:

### Services

| Service | Description | Port |
|---------|-------------|------|
| **nginx** | Load balancer for vote instances | 8000 |
| **vote1** | Voting interface instance 1 | - |
| **vote2** | Voting interface instance 2 | - |
| **result** | Results display | 5050 |
| **worker** | Processes votes from Redis to PostgreSQL | - |
| **redis** | In-memory data store | - |
| **db** | PostgreSQL database | - |
| **seed** | Generates test votes | - |

### Networks

- **front-tier**: Public-facing services (nginx, vote, result)
- **back-tier**: Backend services (redis, postgres, worker)

## Usage

### Initialize Terraform

```bash
cd terraform/part1-docker
terraform init
```

### Preview Changes

```bash
terraform plan
```

### Deploy

```bash
terraform apply
```

After deployment, access the applications at:
- **Voting App**: http://localhost:8000
- **Results App**: http://localhost:5050

### Destroy

```bash
terraform destroy
```

**Note**: The PostgreSQL volume is protected from accidental deletion. If you want to delete it, you must first remove the `prevent_destroy` lifecycle rule in `volumes.tf`.

## Configuration

### Variables

You can customize the deployment by creating a `terraform.tfvars` file:

```hcl
nginx_port = 8000
result_port = 5050
postgres_password = "your_secure_password"
```

### Available Variables

| Variable | Description | Default | Validation |
|----------|-------------|---------|------------|
| `nginx_port` | External port for Nginx | 8000 | Must be 1024-65535 |
| `result_port` | External port for Result app | 5050 | Must be 1024-65535 |
| `postgres_password` | PostgreSQL password | "postgres" | Min 8 characters |

## File Structure

```
terraform/part1-docker/
├── versions.tf      # Provider version constraints
├── providers.tf     # Docker provider configuration
├── variables.tf     # Input variables with validation
├── locals.tf        # Centralized configuration values
├── networks.tf      # Docker networks
├── volumes.tf       # Docker volumes
├── main.tf          # Images and containers
├── outputs.tf       # Output values
└── README.md        # This file
```

## Best Practices Implemented

✅ **Separation of Concerns**: Logical file organization  
✅ **Version Pinning**: Explicit provider versions  
✅ **Input Validation**: Variables have validation rules  
✅ **DRY Principle**: Locals for repeated values  
✅ **Immutability**: Containers use `image_id` instead of `name`  
✅ **Security**: Password marked as sensitive  
✅ **Safety**: Volume protected from accidental deletion  
✅ **Documentation**: Comprehensive comments throughout  

## Troubleshooting

### Docker daemon not running

```
Error: Cannot connect to the Docker daemon
```

**Solution**: Start Docker Desktop

### Port already in use

```
Error: port is already allocated
```

**Solution**: Change the port in `terraform.tfvars` or stop the conflicting service

### Out of disk space

```
Error: No space left on device
```

**Solution**: Run `docker system prune` to free up space

## Development

### Format Code

```bash
terraform fmt -recursive
```

### Validate Configuration

```bash
terraform validate
```

### View State

```bash
terraform show
```

## Learn More

- [Terraform Docker Provider Documentation](https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs)
- [Docker Documentation](https://docs.docker.com/)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)
