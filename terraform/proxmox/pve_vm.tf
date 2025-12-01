
terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "3.0.2-rc04"
    }
  }
}

provider "proxmox" {
  pm_api_url      = var.pm_api_url
  pm_tls_insecure = true
}



resource "proxmox_vm_qemu" "redis_vm" {

  name        = "vm-s23ezzem"
  vmid        = split(".", var.vm_ip)[3]
  target_node = var.target_node
  clone       = "template-debian"
  tags        = "fila3"

  #cloud init config
  os_type = "cloud-init"
  ciuser  = "s23ezzem"
  # cipassword = "iole"
  sshkeys = file(var.ssh_key_path)

  cpu {
    cores   = 1
    sockets = 1
    type    = "host"
  }

  #memory
  memory = "1024"

  #network
  ipconfig0  = "ip=${var.vm_ip}/24,gw=${var.network_config.gateway}"
  nameserver = var.network_config.nameserver
  network {
    id     = 0
    bridge = "vmbr0"
    model  = "virtio"
  }

  #disk
  scsihw = "virtio-scsi-pci"
  disks {
    virtio {
      virtio0 {
        disk {
          size     = "20G"
          storage  = "vg_proxmox"
          iothread = true
        }
      }
    }
    ide {
      ide2 {
        cloudinit {
          storage = "vg_proxmox"
        }
      }
    }
  }

}

resource "null_resource" "reboot_vm" {
  depends_on = [proxmox_vm_qemu.redis_vm]

  provisioner "local-exec" {
    command = <<EOT
      
      # Wait for boot
      sleep 30

      # Stop the VM
      curl -k -X POST -H "Authorization: PVEAPIToken=$PM_API_TOKEN_ID=$PM_API_TOKEN_SECRET" \
        ${var.pm_api_url}/nodes/${var.target_node}/qemu/${split(".", var.vm_ip)[3]}/status/stop

      # Wait for shutdown
      sleep 20

      # Start the VM
      curl -k -X POST -H "Authorization: PVEAPIToken=$PM_API_TOKEN_ID=$PM_API_TOKEN_SECRET" \
        ${var.pm_api_url}/nodes/${var.target_node}/qemu/${split(".", var.vm_ip)[3]}/status/start

      # Wait for boot
      sleep 30
    EOT
  }
}

resource "null_resource" "provision_redis" {
  depends_on = [null_resource.reboot_vm]

  # Upload Redis installation script
  provisioner "file" {
    content = templatefile("${path.module}/../../templates/install-redis.sh.tftpl", {
      password = "redispassword"
    })
    destination = "/tmp/install-redis.sh"

    connection {
      type        = "ssh"
      user        = var.connection_user
      private_key = file("${replace(var.ssh_key_path, ".pub", "")}")
      host        = var.vm_ip
    }
  }

  # Execute Redis installation script
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/install-redis.sh",
      "sudo /tmp/install-redis.sh"
    ]

    connection {
      type        = "ssh"
      user        = var.connection_user
      private_key = file("${replace(var.ssh_key_path, ".pub", "")}")
      host        = var.vm_ip
    }
  }
}

