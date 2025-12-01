# Proxmox VM Provisioning for Redis

This directory contains Terraform configuration to provision a Redis VM on Proxmox.

## VM Freeze Issue

**Note**: The Terraform configuration includes an automated reboot step to handle a known issue where the VM freezes (100% CPU) on first boot. This requires Proxmox API access.

## Deployment Steps

1.  **Configure Credentials (CRITICAL)**:
    You **MUST** export your Proxmox API credentials as environment variables. These are used by Terraform to perform the automated reboot and unfreeze the VM.
    ```bash
    export PM_API_TOKEN_ID='your-token-id'
    export PM_API_TOKEN_SECRET='your-token-secret'
    ```

2.  **Configure Variables**:
    Copy the example variable file and update it with your settings:
    ```bash
    cp terraform.tfvars.example terraform.tfvars
    ```
    Open `terraform.tfvars` and ensure the `vm_ip`, `ssh_key_path`, and user details are correct for your setup.
    *   `vm_ip`: The IP address for your Redis VM (e.g., `10.144.208.105`).
    *   `ssh_key_path`: Path to your public SSH key.

3.  Initialize and Apply:
    ```bash
    terraform init
    terraform apply -auto-approve
    ```
    
    **What happens**:
    -   Terraform creates the VM.
    -   It automatically stops and starts the VM (reboot) to fix the CPU freeze.
    -   It connects via SSH to install and configure Redis.

4.  **Note the VM IP**: You will need the Redis VM's IP address for the Kubernetes deployment.

## Cleanup

To remove the VM:
```bash
terraform destroy
```

## Variables

All variables are defined in `variables.tf` with default values. You can override them by:
- Creating a `terraform.tfvars` file (use `terraform.tfvars.example` as a template)
- Using `-var` flags with terraform commands
- Setting `TF_VAR_*` environment variables

Key variables:
- `pm_api_url`: Proxmox API URL
- `target_node`: Proxmox node to deploy to
- `vm_name`: Name of the VM
- `vm_ip`: IP address for the VM
- `ssh_key_path`: Path to your public SSH key
- `ciuser`: Cloud-init username
- `connection_user`: SSH connection username
