# deploy Redhat OS on fedora linux vm in azure : Fedora Linux 38 by Solve DevOps
# server size : Standard_B2s - 2 vcpus, 4 GiB memory
sudo dnf install -y git wget unzip python3 jq
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo dnf install -y https://packages.microsoft.com/config/rhel/9.0/packages-microsoft-prod.rpm
sudo dnf install -y azure-cli
az login

# Enable nested virtualization
sudo dnf install @virtualization libvirt libvirt-daemon-kvm qemu-kvm
sudo systemctl enable --now libvirtd


crc setup
crc start --pull-secret ~/pull-secret.txt
