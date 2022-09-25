pihole_install() {
    printf "\x1B[01;93m========== Updating system ==========\n\x1B[0m"
    sudo apt update
    sudo apt upgrade -y
    sudo apt-get install -y open-vm-tools curl

    printf "\x1B[01;93m========== Install PiHole ==========\n\x1B[0m"
    curl -sSL https://install.pi-hole.net | bash

    printf "\x1B[01;93m========== Free up port 53 on 0.0.0.0 ==========\n\x1B[0m"
    sudo mkdir -p /etc/systemd/resolved.conf.d
    sudo sh -c "echo -e "[Resolve]\nDNS=127.0.0.1\nDNSStubListener=no" > /etc/systemd/resolved.conf.d/pihole.conf"
    sudo mv /etc/resolv.conf /etc/resolv.conf.backup
    sudo ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf

    printf "\x1B[01;92m================== Done.  ==================\n\x1B[0m\n\n"
}

# Actually do the install. Put in function and run at end to prevent parcial download and execution.
pihole_install
