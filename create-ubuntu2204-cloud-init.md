Create Ubuntu cloud init
NB: change vm id at all occurences if already in use (in this file 8003)

```
wget -q https://cloud-images.ubuntu.com/noble/current/jammy-server-cloudimg-amd64.img
qemu-img resize noble-server-cloudimg-amd64.img 32G
```
```
#sudo qm create 8003 --name "ubuntu-2204-cloudinit-template" --ostype l26 \
    --memory 2048 \
    --agent 1 \
    --bios ovmf --machine pc --efidisk0 data1:0,pre-enrolled-keys=0 \
    --cpu host --socket 1 --cores 2 \
    --vga serial0 --serial0 socket  \
    --net0 virtio,bridge=vmbr0
```
```
qm importdisk 8003 jammy-server-cloudimg-amd64.img local-zfs
qm set 8003 --scsihw virtio-scsi-pci --virtio0 data1:vm-8003-disk-1,discard=ignore
qm set 8003 --boot order=virtio0
qm set 8003 --ide2 data1:cloudinit
```
```
cat << EOF | tee /var/lib/vz/snippets/vendor.yaml
#cloud-config
runcmd:
    - apt update
    - apt install -y qemu-guest-agent
    - systemctl start qemu-guest-agent
    - reboot
EOF
```
```
qm set 8003 --cicustom "vendor=local:snippets/vendor.yaml"
qm set 8003 --tags ubuntu-template,22.04,cloudinit
qm set 8003 --ciuser morris
qm set 8003 --cipassword $(openssl passwd -6 $CLEARTEXT_PASSWORD)
qm set 8003 --sshkeys ~/.ssh/authorized_keys
qm set 8003 --ipconfig0 ip=dhcp
```
```
qm template 8003
```
