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
  # Disable export to OVF since this capability is not supported for MacOS 
  # Silicon chips. We will manually create the OVF and VMDK files as part of
  # the post-processor.
  skip_export = true

  # ISO settings
  iso_url       = var.iso_url
  iso_checksum  = var.iso_checksum
  iso_interface = "virtio"

  # VM settings
  vm_name              = local.vm_name
  guest_os_type        = "Ubuntu_arm64"
  disk_size            = var.disk_size
  memory               = var.memory
  hard_drive_interface = "virtio"
  headless             = true

  # SSH settings
  ssh_username = "vagrant"
  ssh_password = "vagrant"
  ssh_timeout  = "1h"

  # Boot settings
  boot_wait = "5s"
  boot_command = [
    "<enter>",            # Select "Try or Install Ubuntu Server"
    "<wait5>",            # Wait for GRUB menu to load
    "e",                  # Edit mode
    "<down><down><down>", # Navigate to the kernel command line
    "<end>",              # Go to end of line
    " autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/arm64/",
    "<f10>" # Boot with the changes
  ]
  http_directory = "http"

  shutdown_command = "echo 'vagrant' | sudo -S shutdown -P now"
  disable_shutdown = true

  vboxmanage = [
    # Basic hardware first
    ["modifyvm", "{{.Name}}", "--vram", "16"],
    ["modifyvm", "{{.Name}}", "--graphicscontroller", "VMSVGA"],

    # Firmware BEFORE storage
    ["modifyvm", "{{.Name}}", "--firmware", "efi"],

    # Input devices
    ["modifyvm", "{{.Name}}", "--mouse", "ps2"],
    ["modifyvm", "{{.Name}}", "--keyboard", "ps2"],

    # Boot order
    ["modifyvm", "{{.Name}}", "--boot1", "disk"],
    ["modifyvm", "{{.Name}}", "--boot2", "dvd"],
    ["modifyvm", "{{.Name}}", "--boot3", "floppy"],
    ["modifyvm", "{{.Name}}", "--boot4", "none"],

    # Network
    ["modifyvm", "{{.Name}}", "--macaddress1", "080027F0F51D"],
    ["modifyvm", "{{.Name}}", "--nat-localhostreachable1", "on"],

    # Audio
    ["modifyvm", "{{.Name}}", "--audio-driver", "coreaudio"],
    ["modifyvm", "{{.Name}}", "--audio-controller", "hda"],
    ["modifyvm", "{{.Name}}", "--audioin", "off"],
    ["modifyvm", "{{.Name}}", "--audioout", "on"],

    # Other settings
    ["modifyvm", "{{.Name}}", "--rtcuseutc", "on"],
    ["modifyvm", "{{.Name}}", "--usbxhci", "on"],
    ["modifyvm", "{{.Name}}", "--clipboard-mode", "disabled"]
  ]
}

build {
  sources = ["source.virtualbox-iso.ubuntu"]

  # Add any provisioning steps here if needed
  provisioner "shell" {
    scripts = [
      "scripts/arm64/update.sh",
      "scripts/arm64/vagrant.sh",
      "scripts/arm64/guest-additions.sh"
    ]
  }

  # Manually create OVF and VMDK files to create Vagrant box
  provisioner "shell-local" {
    environment_vars = [
      "VM_NAME=${local.vm_name}",
      "MEMORY=${var.memory}",
      "DISK_SIZE=${var.disk_size}",
      "VDI_SOURCE=${path.root}/output-ubuntu/${local.vm_name}.vdi",
      "OUTPUT_DIR=${path.root}/output-vagrant",
      # relative to the output file
      "TEMPLATE_PATH=${path.root}/../templates/ovf.tpl",
      "METADATA_PATH=${path.root}/../templates/metadata.tpl",
      "VAGRANTFILE_PATH=${path.root}/../templates/vagrantfile.tpl",
    ]

    inline = [
      # Initial cleanup of any existing output directory and disks
      "echo 'Cleaning up previous files...'",
      "rm -rf \"$OUTPUT_DIR\"",
      "VBoxManage list hdds | grep Location | grep \"$VM_NAME-disk001.vmdk\" | cut -d: -f2 | xargs -I {} VBoxManage closemedium disk \"{}\" --delete || true",
      "sleep 2",

      # Create fresh output directory
      "echo \"OUTPUT_DIR is set to: $OUTPUT_DIR\"",
      "mkdir -p \"$OUTPUT_DIR\"",

      # Stop VM so we can interact with VDI
      "echo 'Ensuring VM is stopped...'",
      "VBoxManage list runningvms | grep -q \"$VM_NAME\" && VBoxManage controlvm \"$VM_NAME\" poweroff || true",
      "sleep 2",

      # Convert VDI to VMDK
      "echo 'Converting VDI to VMDK...'",
      "VBoxManage clonemedium \"$VDI_SOURCE\" \"$OUTPUT_DIR/$VM_NAME-disk001.vmdk\" --format VMDK --variant StreamOptimized",

      # Verify VMDK creation
      "if [ ! -f \"$OUTPUT_DIR/$VM_NAME-disk001.vmdk\" ]; then echo 'Error: VMDK file was not created!' && exit 1; fi",

      # Get UUIDs
      "echo 'Getting disk UUID...'",
      "disk_uuid=$(VBoxManage showmediuminfo \"$OUTPUT_DIR/$VM_NAME-disk001.vmdk\" | grep 'UUID:' | cut -d: -f2 | awk '{print $1}' | head -n1)",
      "vm_uuid=$(uuidgen)",

      # Export required variables for template
      "export disk_uuid",
      "export vm_uuid",

      # Process templates and generate files
      "echo 'Processing templates...'",
      "cd \"$OUTPUT_DIR\" || exit 1",
      "envsubst < \"$TEMPLATE_PATH\" > \"box.ovf\"",
      "envsubst < \"$METADATA_PATH\" > \"metadata.json\"",
      "envsubst < \"$VAGRANTFILE_PATH\" > \"Vagrantfile\"",

      # Create box file
      "echo 'Creating box file...'",
      "tar -czf \"$VM_NAME.box\" ./metadata.json ./Vagrantfile ./box.ovf ./$VM_NAME-disk001.vmdk",

      # Final cleanup
      "echo 'Performing final cleanup...'",
      "cd .. || exit 1",
      "VBoxManage closemedium disk \"$OUTPUT_DIR/$VM_NAME-disk001.vmdk\" --delete || true",
    ]
  }

  # Upload to HCP Vagrant Registry
  # post-processors {
  #   post-processor "artifice" {
  #     files = ["./output-vagrant/${local.vm_name}.box"]
  #   }
  #   post-processor "vagrant-registry" {
  #     client_id     = var.hcp_client_id
  #     client_secret = var.hcp_client_secret
  #     box_tag      = "im2nguyen/ubuntu-24-04"
  #     version      = "0.1.0"
  #     architecture = var.arch
  #   }
  # }
}