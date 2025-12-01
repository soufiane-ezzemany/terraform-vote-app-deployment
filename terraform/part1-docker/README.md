# Part 1: Local Docker Deployment

This part deploys the entire application stack on your local machine using Docker containers.

## Deployment Steps

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

## Accessing the Application

Once deployed, you can access the services locally:
-   **Voting App**: [http://localhost:8000](http://localhost:8000)
-   **Result App**: [http://localhost:5050](http://localhost:5050)

## Cleanup

To remove all created containers and networks:
```bash
terraform destroy
```
