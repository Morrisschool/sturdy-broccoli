adguard_install() {
    printf "\x1B[01;93m========== Updating system ==========\n\x1B[0m"
    sudo apt update
    sudo apt upgrade -y
    sudo apt-get install -y open-vm-tools

    printf "\x1B[01;93m========== Install AdGuard ==========\n\x1B[0m"
    curl -s -S -L https://raw.githubusercontent.com/AdguardTeam/AdGuardHome/master/scripts/install.sh | sh -s -- -v

    printf "\x1B[01;93m========== Free up port 53 on 0.0.0.0 ==========\n\x1B[0m"
    sudo mkdir -p /etc/systemd/resolved.conf.d
    echo -e "[Resolve]\nDNS=127.0.0.1\nDNSStubListener=no" > /etc/systemd/resolved.conf.d/adguardhome.conf
    sudo mv /etc/resolv.conf /etc/resolv.conf.backup
    sudo ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf

    printf "\x1B[01;92m================== Done.  ==================\n\x1B[0m\n\n"
}

# Actually do the install. Put in function and run at end to prevent parcial download and execution.
adguard_install
