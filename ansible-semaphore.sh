#! /usr/bin/env bash

install() {
    printf "\x1B[01;93m========== Updating system ==========\n\x1B[0m"
    sudo apt update
    sudo apt upgrade -y
    sudo apt-get install -y open-vm-tools

    printf "\x1B[01;93m========== Install Ansible and dependencies ==========\n\x1B[0m"
    sudo apt install --no-install-recommends software-properties-common

}
# Actually do the install. Put in function and run at end to prevent partial download and execution.
install
