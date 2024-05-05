#! /usr/bin/env bash

install() {
    printf "\x1B[01;93m========== Updating system ==========\n\x1B[0m"
    sudo apt update
    sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y
    sudo DEBIAN_FRONTEND=noninteractive apt install -y xdg-utils

    printf "\x1B[01;93m========== Install docker ==========\n\x1B[0m"
    sudo apt-get update
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt update
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    printf "\x1B[01;93m========== Install wasp and add to path ==========\n\x1B[0m"
    curl -sSL https://get.wasp-lang.dev/installer.sh | sh
    echo "export PATH=\$PATH:/root/.local/bin" >> ~/.bashrc

    printf "\x1B[01;93m========== Install nvm ==========\n\x1B[0m"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash
    nvm install 20

    printf "\x1B[01;93m========== Ensure keys exist ==========\n\x1B[0m"
    # Create .ssh/ if it doesn't exist
    [ -d ~/.ssh/ ] || mkdir ~/.ssh
    # Generate passwordless keys if they don't exist
    [ -f ~/.ssh/id_rsa ] || ssh-keygen -N "" -f ~/.ssh/id_rsa
    # Create an authorized_keys file if it doesn't exist
    [ -f ~/.ssh/authorized_keys ] || touch ~/.ssh/authorized_keys
    # Add our key to it if it is not present
    KEY=$(cat ~/.ssh/id_rsa.pub)
    grep -Fxq "$KEY" ~/.ssh/authorized_keys || cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

    printf "\x1B[01;92m================== Done.  ==================\n\x1B[0m\n\n"
}

# Actually do the install. Put in function and run at end to prevent parcial download and execution.
install
