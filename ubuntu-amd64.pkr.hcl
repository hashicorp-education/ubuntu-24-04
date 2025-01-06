packer {
  required_plugins {
    virtualbox = {
      version = ">= 1.0.5"
      source  = "github.com/hashicorp/virtualbox"
    }
    vagrant = {
      version = ">= 1.0.2"
      source  = "github.com/hashicorp/vagrant"
    }
  }
}

locals {
  vm_name = "${var.os_version}-${var.arch}"
}

variable "iso_url" {
  type = string
}

variable "iso_checksum" {
  type = string
}

variable "os_version" {
  type = string
}

variable "arch" {
  type = string
}

variable "memory" {
  type = number
}

variable "disk_size" {
  type = number
}

source "virtualbox-iso" "ubuntu" {
  # ISO settings
  iso_url       = var.iso_url
  iso_checksum  = var.iso_checksum
  iso_interface = "sata"

  # VM settings
  vm_name              = local.vm_name
  guest_os_type        = "Ubuntu_64"
  disk_size            = var.disk_size
  memory               = var.memory
  hard_drive_interface = "sata"
  # headless             = true

  # SSH settings
  ssh_username = "vagrant"
  ssh_password = "vagrant"
  ssh_timeout  = "1h"

  # Boot settings
  boot_wait = "5s"
  boot_command = [
    "e<wait2>",                   # Enter edit mode
    "<down><down><down><wait2>",  # Navigate to the kernel command line
    "<end><wait>",                # Go to the end of the kernel line
    " autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/amd64/<wait>",
    "<f10>" # Boot with the changes
  ]
  http_directory = "http"

  shutdown_command = "echo 'vagrant' | sudo -S shutdown -P now"

  vboxmanage = [
    # Basic hardware
    ["modifyvm", "{{.Name}}", "--vram", "16"],
    ["modifyvm", "{{.Name}}", "--graphicscontroller", "vmsvga"],

    # Firmware and CPU
    ["modifyvm", "{{.Name}}", "--firmware", "efi"],
    ["modifyvm", "{{.Name}}", "--cpu-profile", "host"],
    ["modifyvm", "{{.Name}}", "--pae", "on"],
    ["modifyvm", "{{.Name}}", "--hwvirtex", "on"],
    ["modifyvm", "{{.Name}}", "--vtxvpid", "on"],
    ["modifyvm", "{{.Name}}", "--vtxux", "on"],

    # Input devices
    ["modifyvm", "{{.Name}}", "--mouse", "ps2"],
    ["modifyvm", "{{.Name}}", "--keyboard", "ps2"],

    # Boot order
    ["modifyvm", "{{.Name}}", "--boot1", "disk"],
    ["modifyvm", "{{.Name}}", "--boot2", "dvd"],
    ["modifyvm", "{{.Name}}", "--boot3", "none"],
    ["modifyvm", "{{.Name}}", "--boot4", "none"],

    # Network
    ["modifyvm", "{{.Name}}", "--macaddress1", "080027F0F51D"],
    ["modifyvm", "{{.Name}}", "--nat-localhostreachable1", "on"],

    # Audio
    ["modifyvm", "{{.Name}}", "--audio", "none"],

    # Other settings
    ["modifyvm", "{{.Name}}", "--rtcuseutc", "on"],
    ["modifyvm", "{{.Name}}", "--usb-ohci", "on"],
    ["modifyvm", "{{.Name}}", "--usb-ehci", "off"],
    ["modifyvm", "{{.Name}}", "--clipboard-mode", "disabled"]
  ]
}

build {
  sources = ["source.virtualbox-iso.ubuntu"]

  provisioner "shell" {
    scripts = [
      "scripts/amd64/update.sh",
      "scripts/amd64/vagrant.sh",
      "scripts/amd64/guest-additions.sh"
    ]
  }

  post-processors {
    post-processor "vagrant" {
      output = "output-vagrant/${var.os_version}.box"
    }

    # post-processor "vagrant-registry" {
    #   client_id     = var.hcp_client_id
    #   client_secret = var.hcp_client_secret
    #   box_tag       = "im2nguyen/ubuntu-24-04"
    #   version       = "0.1.0"
    #   architecture  = var.arch
    # }
  }
}