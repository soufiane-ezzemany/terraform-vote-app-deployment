# Cloud Project: Voting App Deployment

This repository contains the Terraform code to deploy a Voting Application using two different methods:
1.  **Local Docker Deployment**: Deploys the full stack (Vote, Result, Worker, Redis, Postgres) locally using the Docker provider.
2.  **Kubernetes + Proxmox Deployment**: Deploys the application services on a Kubernetes cluster and offloads the Redis database to a VM on Proxmox.

## Prerequisites

Ensure you have the following tools installed and configured:
-   [Terraform](https://developer.hashicorp.com/terraform/downloads) (>= 1.0)
-   [Docker Desktop](https://www.docker.com/products/docker-desktop/) (or Docker Engine)
-   [kubectl](https://kubernetes.io/docs/tasks/tools/)
-   Access to the Proxmox cluster and Kubernetes cluster (VPN if required).

## Part 1: Local Docker Deployment

This part deploys the entire application stack on your local machine using Docker containers.

### Deployment Steps

1.  Navigate to the Docker Terraform directory:
    ```bash
    cd terraform/part1-docker
    ```

2.  Initialize Terraform:
    ```bash
    terraform init
    ```

3.  Review the deployment plan:
    ```bash
    terraform plan
    ```

4.  Apply the configuration:
    ```bash
    terraform apply -auto-approve
    ```

### Accessing the Application

Once deployed, you can access the services locally:
-   **Voting App**: [http://localhost:8000](http://localhost:8000)
-   **Result App**: [http://localhost:5050](http://localhost:5050)

### Cleanup

To remove all created containers and networks:
```bash
terraform destroy
```

---

## Part 3: Kubernetes + Redis on Proxmox

This part deploys the stateless services (Vote, Result, Worker) on a Kubernetes cluster and automatically provisions the stateful Redis database on a dedicated Proxmox VM.

### Step 1: Provisioning the Redis VM on Proxmox

**Note on VM Freeze Issue**: The Terraform configuration includes an automated reboot step to handle a known issue where the VM freezes (100% CPU) on first boot. This requires Proxmox API access.

1.  Navigate to the Proxmox Terraform directory:
    ```bash
    cd terraform/proxmox
    ```

2.  **Configure Credentials (CRITICAL)**:
    You **MUST** export your Proxmox API credentials as environment variables. These are used by Terraform to perform the automated reboot and unfreeze the VM.
    ```bash
    export PM_API_TOKEN_ID='your-token-id'
    export PM_API_TOKEN_SECRET='your-token-secret'
    ```

3.  **Configure Variables**:
    Copy the example variable file and update it with your settings:
    ```bash
    cp terraform.tfvars.example terraform.tfvars
    ```
    Open `terraform.tfvars` and ensure the `vm_ip`, `ssh_key_path`, and user details are correct for your setup.
    *   `vm_ip`: The IP address for your Redis VM (e.g., `10.144.208.105`).
    *   `ssh_key_path`: Path to your public SSH key.

4.  Initialize and Apply:
    ```bash
    terraform init
    terraform apply -auto-approve
    ```
    **What happens**:
    -   Terraform creates the VM.
    -   It automatically stops and starts the VM (reboot) to fix the CPU freeze.
    -   It connects via SSH to install and configure Redis.

5.  **Note the VM IP**: You will need the Redis VM's IP address for the Kubernetes deployment.

### Step 2: Deploying Application to Kubernetes

1.  Navigate to the Kubernetes Terraform directory:
    ```bash
    cd ../part2-kubernetes
    ```

2.  **Configure Kubeconfig**:
    Place your Kubernetes configuration file in the `config/` directory:
    ```bash
    cp /path/to/your/kubeconfig config/kubeconfig
    ```

3.  **Configure Variables**:
    Copy the example variable file and update it with your settings:
    ```bash
    cp terraform.tfvars.example terraform.tfvars
    ```
    Open `terraform.tfvars` and configure:
    *   `namespace`: Your Kubernetes namespace (e.g., `s23ezzem`)
    *   `node_ip`: The IP address of your Kubernetes node for accessing services
    *   `redis_vm_ip`: The IP address of your Redis VM from Step 1

4.  Initialize and Apply:
    ```bash
    terraform init
    terraform apply -auto-approve
    ```

### Accessing the Application

After deployment, Terraform will output the direct URLs:
-   **Voting App**: Use the `vote_url` from the output
-   **Result App**: Use the `result_url` from the output

Example output:
```
Outputs:

namespace = "s23ezzem"
result_url = "http://10.144.208.102:32388"
vote_url = "http://10.144.208.102:31146"
```

### Cleanup

1.  **Destroy Kubernetes Resources**:
    ```bash
    cd terraform/part2-kubernetes
    terraform destroy
    ```

2.  **Destroy Proxmox VM**:
    ```bash
    cd ../proxmox
    terraform destroy
    ```

---

## Project Structure

-   `terraform/part1-docker`: Terraform code for local Docker deployment.
-   `terraform/part2-kubernetes`: Terraform code for Kubernetes deployment.
-   `terraform/proxmox`: Terraform code for Proxmox VM provisioning.
-   `k8s-manifests`: Kubernetes YAML manifests used by Part 2.
-   `voting-services`: Source code for the application services.

---

## Technical Choices and Design Decisions

### Infrastructure Architecture

**Why Redis on a Separate VM?**
- **Separation of Concerns**: Stateful services (databases) are isolated from stateless application services
- **Performance**: Dedicated VM resources ensure consistent Redis performance without competing with application pods
- **Data Persistence**: VM-based storage provides more reliable data persistence than ephemeral Kubernetes volumes
- **Scalability**: Independent scaling of the database tier without affecting application deployments

**External Service Pattern (Redis Endpoints)**
- We use Kubernetes `Service` without a selector + manual `Endpoints` to treat the external VM as an internal service
- This allows application pods to connect to Redis using standard Kubernetes DNS (`redis:6379`)
- The Redis IP is dynamically injected via Terraform variables for easy configuration

### Terraform Best Practices

**Variable Management**
- All environment-specific values (IPs, namespaces, node names) are externalized as variables
- `terraform.tfvars.example` files provide templates for easy setup
- Default values are provided for non-sensitive configuration to simplify development
- Critical values (API tokens) are managed via environment variables for security

**Module Organization**
- **Reusable `k8s-manifest` module**: Abstracts Kubernetes manifest deployment with namespace injection
- **Consolidated `applications.tf`**: All application deployments in one file for easy maintenance
- **Separation of infrastructure files**: `provider.tf`, `variables.tf`, `outputs.tf` remain separate for clarity

**VM Freeze Automation**
- **Problem**: Proxmox VMs freeze (100% CPU) on first boot, requiring manual intervention
- **Solution**: Automated reboot using Proxmox API (`null_resource` with `local-exec`)
  - Terraform creates the VM
  - Automatically stops and starts it via API to unfreeze
  - Then provisions Redis via SSH
- **Why this approach?**: Eliminates manual steps, makes deployment fully automated

### Continuous Integration (CI)

**Added CI for:**
- **Code Quality**: Automated Terraform validation (`terraform fmt`, `terraform validate`) ensures code consistency
- **Early Error Detection**: Catches syntax errors and configuration issues before deployment

**CI Implementation**
- Pre-commit hooks or GitHub Actions validate Terraform syntax
- Automated checks run on every pull request
- Prevents broken configurations from being merged to main branch
