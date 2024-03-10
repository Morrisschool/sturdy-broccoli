#! /usr/bin/env bash

install() {
    printf "\x1B[01;93m========== Updating system and installing reqs. ==========\n\x1B[0m"
    sudo apt update
    sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y
    sudo DEBIAN_FRONTEND=noninteractive apt install -y tasksel xrdp wget apt-transport-https gnupg2 software-properties-common
    snap remove --purge firefox
    wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null
    gpg -n -q --import --import-options import-show /etc/apt/keyrings/packages.mozilla.org.asc | awk '/pub/{getline; gsub(/^ +| +$/,""); print "\n"$0"\n"}'
    echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | sudo tee -a /etc/apt/sources.list.d/mozilla.list > /dev/null
    echo '\nPackage: *\nPin: origin packages.mozilla.org\nPin-Priority: 1000\n' | sudo tee /etc/apt/preferences.d/mozilla
    sudo apt update
    sudo apt install firefox
    sudo tasksel install ubuntu-desktop-minimal

    ufw allow 22
    ufw allow 3389
    ufw enable
    ufw reload
}

# Actually do the install. Put in function and run at end to prevent parcial download and execution.
install
