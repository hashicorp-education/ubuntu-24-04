#!/bin/bash
set -e

export DEBIAN_FRONTEND=noninteractive
sudo apt-get update
sudo apt-get upgrade -y

sudo apt-get install -y \
    qemu-guest-agent \
    cloud-init \
    software-properties-common \
    curl \
    wget \
    vim \
    git \
    net-tools

sudo apt-get autoremove -y
sudo apt-get clean
sudo rm -rf /var/lib/apt/lists/*

sudo touch /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg
echo "network: {config: disabled}" | sudo tee /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg

echo "System update and Vagrant preparation complete."
