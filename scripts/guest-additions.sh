#!/bin/bash
set -e

# Install required packages
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update
sudo apt-get install -y \
    build-essential \
    dkms

# Create mount point and temporary directory
sudo mkdir -p /media/VBoxGuestAdditions
cd /tmp

# Download VirtualBox Guest Additions
echo "Downloading VirtualBox Guest Additions..."
wget https://download.virtualbox.org/virtualbox/7.1.0_BETA2/VBoxGuestAdditions_7.1.0_BETA2.iso

# Mount the ISO
echo "Mounting Guest Additions ISO..."
sudo mount -o loop,ro VBoxGuestAdditions_7.1.0_BETA2.iso /media/VBoxGuestAdditions

# Install Guest Additions
echo "Installing VirtualBox Guest Additions..."
sudo sh /media/VBoxGuestAdditions/VBoxLinuxAdditions-arm64.run || true

# Clean up
echo "Cleaning up..."
sudo umount /media/VBoxGuestAdditions
sudo rmdir /media/VBoxGuestAdditions
rm VBoxGuestAdditions_7.1.0_BETA2.iso

echo "VirtualBox Guest Additions installation complete."