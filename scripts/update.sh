#!/bin/bash
set -e

# Update package lists
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update

# Upgrade all packages
sudo apt-get upgrade -y

# Install common utilities and cloud-init
sudo apt-get install -y \
    qemu-guest-agent \
    cloud-init \
    software-properties-common \
    curl \
    wget \
    vim \
    git \
    net-tools

# Clean up package cache
sudo apt-get autoremove -y
sudo apt-get clean
sudo rm -rf /var/lib/apt/lists/*

# Ensure cloud-init is configured for Vagrant
sudo touch /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg
echo "network: {config: disabled}" | sudo tee /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg

echo "System update and Vagrant preparation complete."
