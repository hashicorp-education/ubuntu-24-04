#!/bin/bash
set -e

export DEBIAN_FRONTEND=noninteractive

if ! id vagrant &>/dev/null; then
    useradd -m -s /bin/bash vagrant
fi

sudo mkdir -p /home/vagrant/.ssh
sudo chmod 700 /home/vagrant/.ssh

sudo curl -Lo /home/vagrant/.ssh/authorized_keys https://raw.githubusercontent.com/hashicorp/vagrant/master/keys/vagrant.pub
sudo chmod 600 /home/vagrant/.ssh/authorized_keys
sudo chown -R vagrant:vagrant /home/vagrant/.ssh

echo "vagrant ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/vagrant
sudo chmod 440 /etc/sudoers.d/vagrant
sudo visudo -c -f /etc/sudoers.d/vagrant

sudo systemctl restart ssh.service

echo "Vagrant user and SSH configuration complete."

