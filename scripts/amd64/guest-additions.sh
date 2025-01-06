#!/bin/bash
set -e

export DEBIAN_FRONTEND=noninteractive
sudo apt-get update
sudo apt-get install -y \
    build-essential \
    dkms \
    linux-headers-$(uname -r)

sudo mkdir -p /media/VBoxGuestAdditions
cd /tmp

echo "Downloading VirtualBox Guest Additions..."
wget https://download.virtualbox.org/virtualbox/7.1.0_BETA2/VBoxGuestAdditions_7.1.0_BETA2.iso

echo "Mounting Guest Additions ISO..."
sudo mount -o loop,ro VBoxGuestAdditions_7.1.0_BETA2.iso /media/VBoxGuestAdditions

echo "Installing VirtualBox Guest Additions..."
sudo sh /media/VBoxGuestAdditions/VBoxLinuxAdditions.run || true

echo "Cleaning up..."
sudo umount /media/VBoxGuestAdditions
sudo rmdir /media/VBoxGuestAdditions
rm VBoxGuestAdditions_7.1.0_BETA2.iso

echo "VirtualBox Guest Additions installation complete."
