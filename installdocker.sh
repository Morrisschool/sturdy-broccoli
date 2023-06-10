#! /usr/bin/env bash

docker_install() {
    printf "\x1B[01;93m========== Updating system ==========\n\x1B[0m"
    sudo apt update
    sudo apt upgrade -y
    sudo apt install -y open-vm-tools apt-transport-https ca-certificates curl gnupg lsb-release

    printf "\x1B[01;93m========== Install make and docker ==========\n\x1B[0m"
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo apt update
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

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
    sudo groupadd docker
    sudo usermod -aG docker morris

    printf "\x1B[01;92m================== Done.  ==================\n\x1B[0m\n\n"
}

# Actually do the install. Put in function and run at end to prevent parcial download and execution.
docker_install
