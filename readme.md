VBoxManage setextradata global "VBoxInternal/Devices/pcbios/0/Config/DebugLevel"

cd output-vagrant
tar -czf ubuntu-24-04-arm64.box ./metadata.json ./Vagrantfile ./box.ovf ubuntu-24-04-arm64-disk001.vmdk

cd ..
vagrant box add ubuntu_24_04_arm64 output-vagrant/ubuntu-24-04-arm64.box 
mkdir vagrant_project
cd vagrant_project
vagrant init ubuntu_24_04_arm64

vagrant up --provider virtualbox

cd ..
vagrant box remove ubuntu_24_04_arm64
rm -rf vagrant_project/

VBoxManage list hdds
VBoxManage closemedium disk ed12d945-5d5f-4413-9267-09fd823d3b7f --delete