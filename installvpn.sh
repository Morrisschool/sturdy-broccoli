#! /usr/bin/env bash

install() {
    printf "\x1B[01;93m========== Updating system ==========\n\x1B[0m"
    sudo apt update
    sudo apt upgrade -y
    sudo apt-get install -y open-vm-tools

    printf "\x1B[01;93m========== Install OpenVPN and dependencies ==========\n\x1B[0m"
    sudo apt -y install ca-certificates wget net-tools gnupg
    sudo wget -qO - https://as-repository.openvpn.net/as-repo-public.gpg | sudo apt-key add -
    sudo sh -c "echo 'deb http://as-repository.openvpn.net/as/debian jammy main' > /etc/apt/sources.list.d/openvpn-as-repo.list"
    sudo apt update && sudo apt -y install openvpn-as

}
# Actually do the install. Put in function and run at end to prevent parcial download and execution.
install
