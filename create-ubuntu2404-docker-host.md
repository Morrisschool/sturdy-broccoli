Create Ubuntu cloud init with docker
NB: change vm id at all occurences if already in use (in this file 8002)

```
wget -q https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img
qemu-img resize noble-server-cloudimg-amd64.img 32G
```
```
qm create 8002 --name "ubuntu-2404-cloudinit-template" --ostype l26 \
    --memory 2048 \
    --agent 1 \
    --bios ovmf --machine pc --efidisk0 data1:0,pre-enrolled-keys=0 \
    --cpu host --socket 1 --cores 2 \
    --vga serial0 --serial0 socket  \
    --net0 virtio,bridge=vmbr0
```
```
qm importdisk 8002 noble-server-cloudimg-amd64.img data1
qm set 8002 --scsihw virtio-scsi-pci --virtio0 data1:vm-8001-disk-1,discard=ignore
qm set 8002 --boot order=virtio0
qm set 8002 --ide2  data1:cloudinit
```
```
cat << EOF | tee /var/lib/vz/snippets/vendor.yaml
#cloud-config
runcmd:
    - apt update
    - apt install -y qemu-guest-agent
    - systemctl start qemu-guest-agent
    - curl -fsSL https://get.docker.com | sh
    - usermod -aG docker morris
    - reboot
EOF
```
```
qm set 8002 --cicustom "vendor=local:snippets/vendor.yaml"
qm set 8002 --ciuser morris
qm set 8002 --cipassword $(openssl passwd -6 $CLEARTEXT_PASSWORD)
qm set 8002 --ipconfig0 ip=dhcp
qm set 8002 --sshkeys ~/.ssh/authorized_keys
```
```
qm template 8002
```
