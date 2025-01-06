## Ubuntu 24.04

This repository contains the Packer files to build Ubuntu 24.04 Vagrant boxes
for ARM64 and AMD64.

To build the Vagrantboxes, enter the following commands:

```
packer init ubuntu-arm64.pkr.hcl
packer build -var-file="arm64.pkrvars.hcl" ubuntu-arm64.pkr.hcl
packer build -var-file="amd64.pkrvars.hcl" ubuntu-amd64.pkr.hcl
```

With debugging:

```
PACKER_LOG=debug PACKER_LOG_PATH=ubuntu.log packer build -var-file="arm64.pkrvars.hcl" ubuntu-arm64.pkr.hcl
PACKER_LOG=debug PACKER_LOG_PATH=ubuntu.log packer build -var-file="amd64.pkrvars.hcl" ubuntu-amd64.pkr.hcl
```

Packer will spin up the Ubuntu image and configure it for Vagrant. It will 
generate the files in `output-vagrant`. 

For ARM64, this Packer configuration currently uses a workaround for building 
the Vagrantbox since you cannot export VMs to OVF files in VirtualBox MacOS 
with Silicion (ARM64).

To manually build the Vagrantbox:

```
cd output-vagrant
tar -czf ubuntu-24-04-arm64.box ./metadata.json ./Vagrantfile ./box.ovf ./ubuntu-24-04-arm64-disk001.vmdk
```

### Test Vagrantbox

If you install VirtualBox on MacOS, you may need to disable this DebugLevel
configuration. With this default configuration, VirtualBox is unable to spin
up the ARM64 image.

```
VBoxManage setextradata global "VBoxInternal/Devices/pcbios/0/Config/DebugLevel"
```

Install the box.

```
vagrant box add ubuntu_24_04 output-vagrant/ubuntu-24-04-arm64.box 
```

Create a working "test" directory and navigate into it.

```
mkdir vagrant_project
cd vagrant_project
```

Initialize a Vagrant project, using the `ubuntu_24_04` as the base box.

```
vagrant init ubuntu_24_04
```

Spin up your Ubuntu virtual environment

```
vagrant up --provider virtualbox
```

To clean up your environment:

```
cd ..
vagrant box remove ubuntu_24_04
rm -rf vagrant_project/
```

You may need to delete stray disks to completely clean up the Packer buidl. 
First, list and identify the stray disks, then delete them.

```
VBoxManage list hdds
VBoxManage closemedium disk ${disk_uuid} --delete
```
