
terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "3.0.2-rc04"
    }
  }
}

provider "proxmox" {
  pm_api_url      = "https://10.144.208.52:8006/api2/json"
  pm_tls_insecure = true
}

variable "vm_ip" {
  default = "10.144.208.111" # e.g. 10.144.208.122
}

variable "ssh_key_path" {
  default = "/Users/lgfquentin/.ssh/id_ed25519.pub"
}

variable "redis_password" {
  description = "Password for Redis authentication"
  type        = string
  default     = "redispassword"
  sensitive   = true
}

variable "network_config" {
  default = {
    gateway    = "10.144.208.1"
    nameserver = "10.44.10.98"
  }
}

resource "proxmox_vm_qemu" "redis_vm" {

  name        = "vm-q23legof"
  vmid        = split(".", var.vm_ip)[3]
  target_node = "dapi-na-cours-pve-03"
  clone       = "template-debian"
  tags        = "fila3"

  #cloud init config
  os_type = "cloud-init"
  ciuser  = "q23legof"
  # cipassword = "iole"
  sshkeys = file(var.ssh_key_path)

  # Auto-install Redis on first boot via remote-exec
  provisioner "remote-exec" {
    inline = [
      "sudo DEBIAN_FRONTEND=noninteractive apt-get update -q",
      "sudo DEBIAN_FRONTEND=noninteractive apt-get install -q -y redis",
      "sudo sed -e '/^bind/s/bind.*/bind 0.0.0.0/' -i /etc/redis/redis.conf",
      "sudo sed -e '/# requirepass/s/.*/requirepass ${var.redis_password}/' -i /etc/redis/redis.conf",
      "sudo systemctl restart redis-server.service",
      "sudo systemctl enable redis-server.service"
    ]

    connection {
      type        = "ssh"
      user        = "q23legof"
      private_key = file("${replace(var.ssh_key_path, ".pub", "")}")
      host        = var.vm_ip
    }
  }

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
          storage  = "local-zfs"
          iothread = true
        }
      }
    }
    ide {
      ide2 {
        cloudinit {
          storage = "local-zfs"
        }
      }
    }
  }

}

