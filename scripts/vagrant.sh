#!/bin/bash
set -e

# Update package lists
export DEBIAN_FRONTEND=noninteractive

# Create Vagrant user if not exists
if ! id vagrant &>/dev/null; then
    useradd -m -s /bin/bash vagrant
fi

# Prepare for Vagrant
sudo mkdir -p /home/vagrant/.ssh
sudo chmod 700 /home/vagrant/.ssh

# Add insecure Vagrant SSH key
sudo curl -Lo /home/vagrant/.ssh/authorized_keys https://raw.githubusercontent.com/hashicorp/vagrant/master/keys/vagrant.pub
sudo chmod 600 /home/vagrant/.ssh/authorized_keys
sudo chown -R vagrant:vagrant /home/vagrant/.ssh

# Configure sudoers for Vagrant
echo "vagrant ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/vagrant
sudo chmod 440 /etc/sudoers.d/vagrant
sudo visudo -c -f /etc/sudoers.d/vagrant

# Disable SSH password authentication
# sed -i 's/^#*PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
# sed -i 's/^#*PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config

# Restart SSH service to apply changes
sudo systemctl restart ssh.service

echo "Vagrant user and SSH configuration complete."