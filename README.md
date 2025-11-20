FILA3 Voting App Terraform Project
===================================

# Table of Content

  * [Local Docker deployment](#part-1---local-docker-deployment)
  * [Kubernetes deployment](#part-2---kubernetes)
  * [Offloading Redis from the Cluster](#part-3---proxmox-kubernetes-and-offloaded-redis)

## Objectives

The objective is to use _only_ Terraform to deploy the entirety of the voting app.

The tutorial on Terraform did not give you _all_ elements for this project: this was on purpose.
The point is for you to learn how to seek information in providers and other documentations.
But most elements in the tutorials can be directly applied.

Different levels are possible, the more advancement you make the better.
<!-- **Part 1 and Part 2 are mandatory.** -->


## Part 1 - Local Docker deployment

![voting-app-docker](figures/login-nuage-voting.drawio.svg)

In this first part, you must write Terraform code that deploys the application with the Docker provider.
The app will thus be deployed locally inside containers on your machine.
Use the given `docker-compose.yml` as a reference configuration.

**TIP**: Recall that a Docker Compose "service" creates a DNS records accessible by other containers.
Terraform does not do that, so you will need to add the relevant `host` configurations.


## Part 2 - Kubernetes

![voting-app-k8s](figures/login-nuage-voting-k8s.drawio.svg)

In this second part, you must write code that deploys the application onto a Kubernetes cluster.
Reuse the configuration that was set in the tutorial.
Use the given manifests in `k8s-manifests/`.

**IMPORTANT**: There is _a single cluster for everyone_. You must deploy manifest inside _your own_ Kubernetes namespace. It has the same name than your login identifier. All your resources _must_ be deployed within your namespace. When using `kubectl get`, the default namespace is `default`, you must have to add `-n e22diant` to view your namespace.

__Install kubenv__, [see kubectx](https://github.com/ahmetb/kubectx)

**TIP**: You can use the `kubernetes_manifest` resource and provide any YAML manifest file directly.

Make sure to organize your Terraform code well. Attention will be given to your organization (modules, directories, files)


## Part 3 - Proxmox, Kubernetes and offloaded Redis

In this last part, the objective is to deploy with Terraform the Redis database inside a Proxmox VM rather than on the cluster.

### Kubernetes manifests update

The database must be available to the other components of the application located on the cluster.
You will have to update the Kubernetes manifests, notably, the previous Redis `service` must be changed to a "headless" service.

**TIP**: *vote* and *worker* need to be aware of the Redis host IP and password.


### Proxmox setup

The main endpoint to the Proxmox server is `10.144.208.51:8006` accessible with your browser.
You can connect with the provided login and password. The realm is `Proxmox VE authentication server`.

Then, create an API token for Terraform: "Datacenter" > "Permissions" > "API Tokens" > "Add".
The token ID is irrelevant, chose something meaningful like "terraform-token".
Make sure to _uncheck_ `Privilege Separation`.
Save the token credentials safely in your machine, then export environment variables

```
export PM_API_TOKEN_ID='e23diant@pve!terraform-token'
export PM_API_TOKEN_SECRET='FIXME'
```

Try to `plan` inside `terraform/proxmox/pve_vm.tf`.

### VM deployment

You will use the `vm_qemu` resource of the Telmate provider to deploy your VM.
See [the documentation](https://registry.terraform.io/providers/Telmate/proxmox/latest/docs/resources/vm_qemu)

The script to deploy a clone of the Debian template VM is located in `terraform/proxmox/pve_vm.tf`.
Update the `FIXME`s with your informations ; deploy with `apply` and check the dashboard.

When booting, the VM will use some CPU and it is normal. But if the VM uses 100% CPU after ~45s of uptime, consider stopping and restarting the VM.

If everything seem okay, try to connect to the VM with SSH.

### Manual Redis installation and Kubernetes connection

To install Redis upon startup of the VM, there is a given `install-redis.sh.tftpl` template script that must be instantiated with a password and executed inside the VM.

At first, add your password manually in the script, and execute it directly in the VM.

Deploy the application ; debug ; repeat, until it works.

### Automatic installation

We would like to use Terraform as a source of truth for our whole infrastructure and application.
There are multiple solutions to install Redis in the VM:

* Use a [Terraform _provisioner_](https://developer.hashicorp.com/terraform/language/provisioners)
* Use Ansible and then a Terraform `null-resource` to run your playbook.
* Use _cloud-init_ directly with the Proxmox VM resource.



## Kubernetes Debugging tips

* Ping from inside a Deployment's pod:
  * Launch bash on a pod, e.g.: `kubectl exec deployments/vote-deplt -it -- bash` then
  * Install the `ping` command: `apt update; apt install iputils-ping`
  * Check connectivity: `ping redis -p 6379`

* Pod for debugging networking: https://hub.docker.com/r/rtsp/net-tools
  * Start the pod: `kubectl run net-debug --image rtsp/net-tools`, then
  * Launch an interactive bash session: `kubectl exec net-debug -it -- bash` or
  * Launch a single command, e.g.: `kubectl exec net-debug -- nslookup redis`

* Pod for debugging Redis:
  * Start the pod: `kubectl run redis-debug --image redis:alpine`
  * Check the connection: `kubectl exec redis-debug -it -- redis-cli -h redis -pass '{yourpassword}'`


## Destroy everything

Do not forgot to destroy all resources, especially the K8S cluster.
```
$ terraform destroy
```

If you forgot to add `deletion_protection = true` in the Terraform cluster resource, you can modify the state directly.
*This is not good practice.*

```
    sed -e '/deletion_protection/s/true/false/' -i terraform.tfstate
```

