# Kubernetes Deployment

This directory contains Terraform configuration to deploy the voting application on Kubernetes.

## Prerequisites

- Access to a Kubernetes cluster
- Kubeconfig file for cluster authentication
- Redis VM already provisioned (see `terraform/proxmox` directory)

## Deployment Steps

1.  **Configure Kubeconfig**:
    Place your Kubernetes configuration file in the `config/` directory:
    ```bash
    cp /path/to/your/kubeconfig config/kubeconfig
    ```

2.  **Configure Variables**:
    Copy the example variable file and update it with your settings:
    ```bash
    cp terraform.tfvars.example terraform.tfvars
    ```
    Open `terraform.tfvars` and configure:
    *   `namespace`: Your Kubernetes namespace (e.g., `s23ezzem`)
    *   `node_ip`: The IP address of your Kubernetes node for accessing services
    *   `redis_vm_ip`: The IP address of your Redis VM from the Proxmox deployment

3.  Initialize and Apply:
    ```bash
    terraform init
    terraform apply -auto-approve
    ```

## Accessing the Application

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

## Cleanup

To remove all Kubernetes resources:
```bash
terraform destroy
```

## Architecture

### External Redis Service

The application connects to an external Redis instance running on a Proxmox VM. This is achieved using:
- **Kubernetes Service (without selector)**: Defines the service endpoint named `redis`
- **Kubernetes Endpoints**: Manually maps the service to the external VM IP address

Application pods connect to Redis using the standard DNS name `redis:6379`, which Kubernetes resolves to the external VM.

### Module Structure

- **`modules/k8s-manifest`**: Reusable module for deploying Kubernetes manifests with namespace injection
- **`applications.tf`**: All application deployments consolidated in one file for easy maintenance

## Variables

Key variables:
- `namespace`: Kubernetes namespace for resources
- `node_ip`: IP address of Kubernetes node (for accessing NodePort services)
- `redis_vm_ip`: IP address of the external Redis VM
- `kubeconfig_path`: Path to kubeconfig file (default: `./config/kubeconfig`)
