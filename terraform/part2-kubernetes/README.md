# Part 2: Kubernetes Deployment with Terraform

This directory contains Terraform configuration for deploying the Voting App to a Kubernetes cluster. It uses a **Module-Based Architecture** to dynamically ingest existing YAML manifests, ensuring a clean and maintainable codebase.

## Prerequisites

- **Terraform** >= 1.0
- **Kubectl** configured with access to the cluster
- **Kubeconfig** file located at `./config/kubeconfig` (or configured via environment)

## Architecture

The application is deployed to a specific namespace (`q23legof`) and consists of the following components:

### Services

| Service | Description | Type | Port |
|---------|-------------|------|------|
| **vote** | Voting interface | NodePort | 31000+ |
| **result** | Results display | NodePort | 31000+ |
| **redis** | In-memory data store | NodePort | 6379 |
| **db** | PostgreSQL database | ClusterIP | 5432 |
| **worker** | Background processor | Deployment | - |
| **seed-job** | Data seeder | Job | - |

### Module Architecture

This project uses a custom local module `modules/k8s-manifest` to:
1.  **Read** standard Kubernetes YAML manifests from `../../k8s-manifests/`.
2.  **Decode** the YAML into Terraform objects.
3.  **Inject** the target namespace dynamically.
4.  **Patch** specific resources (e.g., PostgreSQL storage) on the fly.

## Usage

### Initialize Terraform

```bash
cd terraform/part2-kubernetes
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

### Access the Application

After deployment, Terraform will output the direct URLs to access the application:

```bash
# Example Output
namespace = "q23legof"
result_url = "http://10.144.208.131:port" #ip for cluster 52, change it to 102 instead of 131 to get 51
vote_url = "http://10.144.208.131:port" #ip for cluster 52, change it to 102 instead of 131 to get 51
```

You can also retrieve these later with:

```bash
terraform output
```

### Destroy

```bash
terraform destroy
```

## Configuration

### Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `namespace` | Kubernetes namespace | `q23legof` |
| `kubeconfig_path` | Path to kubeconfig | `./config/kubeconfig` |

## File Structure

```
terraform/part2-kubernetes/
├── apps.tf          # Application components (Vote, Result, Worker, Seed)
├── db.tf            # Database components (Redis, PostgreSQL)
├── locals.tf        # Shared configuration (manifest paths)
├── moves.tf         # State migration (Zero-Downtime)
├── outputs.tf       # Access URLs
├── provider.tf      # Kubernetes provider config
├── variables.tf     # Input variables
├── modules/
│   └── k8s-manifest/ # Reusable manifest ingestion module
└── config/
    └── kubeconfig   # Cluster credentials
```

## Best Practices Implemented

✅ **Module-Based Architecture**: Reusable logic for manifest handling  
✅ **Infrastructure as Data**: Reads directly from upstream YAML files  
✅ **Zero Repetition**: DRY principle applied via modules  
✅ **Zero Downtime**: State migration using `moved` blocks  
✅ **Dynamic Patching**: On-the-fly modification of manifests (e.g., PVC replacement)  
✅ **Namespace Isolation**: All resources confined to user namespace  

## Troubleshooting

### Connection Refused (Seed Job)
If the seed job fails with connection refused, it likely started before the Vote service was ready. It is configured with `depends_on` to mitigate this, but if it happens, simply re-run:
```bash
terraform apply -target=module.seed_job
```

### PostgreSQL Pending
If the PostgreSQL pod is pending, ensure the `emptyDir` patch is correctly applied. The module handles this automatically in `db.tf`.

### Seed Job Error
If the seed job fails with connection refused, it likely started before the Vote service was ready. It is configured with `depends_on` to mitigate this, but if it happens, simply re-run:
```bash
# Set KUBECONFIG
export KUBECONFIG=./config/kubeconfig

# Destroy Terraform resources
terraform destroy -auto-approve

# Clean up orphaned pods
kubectl delete pods --all -n q23legof --ignore-not-found=true
```
