#! /usr/bin/env bash

install() {
    printf "\x1B[01;93m========== Updating system ==========\n\x1B[0m"
    sudo apt update
    sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y

    printf "\x1B[01;92m================== Rebooting...  ==================\n\x1B[0m\n\n"
    sudo reboot now
}

# Actually do the install. Put in function and run at end to prevent parcial download and execution.
install
