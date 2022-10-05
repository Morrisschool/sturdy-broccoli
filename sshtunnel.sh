#! /usr/bin/env bash

sshtunnel_install() {
    printf "\x1B[01;93m========== Input variables ==========\n\x1B[0m"
    read -p "Enter domainname tunnel is used for: " DOMAIN
    read -p "Enter public IP for cloudproxy: " CLOUDIP
    read -p "Enter user on cloudproxy: " CLOUDUSER
    read -p "Enter external port for forwarding: " EXTPORT
    read -p "Enter internal port for forwarding: " INTPORT

    printf "\x1B[01;93m========== Create certificates for tunnel ==========\n\x1B[0m"
    ssh-keygen -t ed25519 -C $DOMAIN -f $DOMAIN.tunnel -N ""
    USERNAME=$(id -un)
    mv $DOMAIN.tunnel /home/${USERNAME}/.ssh/${DOMAIN}.tunnel

    printf "\x1B[01;93m========== Create identityfile for tunnel ==========\n\x1B[0m"
    touch /home/${USERNAME}/.ssh/${DOMAIN}.tunnel.id
    sudo bash -c "cat <<-EOF > /home/"$USERNAME"/test/"$DOMAIN".tunnel.id
    Host "$DOMAIN"
        Hostname "$CLOUDIP"
        User "$CLOUDUSER"
        IdentityFile /home/"$USERNAME"/.ssh/"$DOMAIN".tunnel
        IdentitiesOnly yes
    EOF"

    printf "\x1B[01;93m========== Setup tunnel.service ==========\n\x1B[0m"
    sudo touch /etc/systemd/system/${DOMAIN}.tunnel.service
    sudo bash -c "cat <<-EOF > /etc/systemd/system/"$DOMAIN".tunnel.service
    [Unit]
    Description=Maintain Tunnel to cloud reverse proxy
    After=network.target

    [Service]
    User="$USER"
    ExecStart=/usr/bin/ssh -i ~/.ssh/"$DOMAIN".tunnel -o ServerAliveInterval=60 -o ExitOnForwardFailure=yes -gnNT -R "$EXTPORT":localhost:"$INTPORT" "$CLOUDUSER"@"$DOMAIN" vmstat 5
    RestartSec=15
    Restart=always
    KillMode=mixed

    [Install]
    WantedBy=multi-user.target
    EOF'

    while true; do
    read -p "Is the public key installed on the Cloud proxy? " YN
    case $YN in
        [yY] ) break;;
        [nN] ) echo "Run the following command after installing the created public key on the Cloud proxy:"
            echo "bash <(curl -s https://raw.githubusercontent.com/Morrisschool/sturdy-broccoli/main/sshtunnel_activation.sh)"
            echo ${DOMAIN}.tunnel.service > /home/"$USERNAME"/tunnelname
            exit;;
        * ) echo invalid response;;
    esac

    done

    printf "\x1B[01;93m========== Reload daemon, enable service on startup, start service ==========\n\x1B[0m"
    sudo systemctl daemon-reload
    sudo systemctl enable $DOMAIN.tunnel
    sudo systemctl start $DOMAIN.tunnel

    printf "\x1B[01;92m================== Done.  ==================\n\x1B[0m\n\n"
    sudo systemctl status $DOMAIN.tunnel
}

# Actually do the install. Put in function and run at end to prevent parcial download and execution.
sshtunnel_install
