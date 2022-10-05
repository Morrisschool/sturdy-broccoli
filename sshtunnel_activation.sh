#! /usr/bin/env bash

sshtunnel_activation() {
    printf "\x1B[01;93m========== Tunnel name ==========\n\x1B[0m"
    TUNNEL=$(ls /etc/systemd/system/ | grep tunnel)
    echo $TUNNEL

    while true; do

	case $YN in
        [yY] ) printf "\x1B[01;93m========== Reload daemon, enable service on startup, start service ==========\n\x1B[0m"
            sudo systemctl daemon-reload
            sudo systemctl enable $TUNNEL
            sudo systemctl start $TUNNEL
            break;;
        [nN] ) read -p "Please enter the name of the tunnel you want to start: " TUNNELNAME
            printf "\x1B[01;93m========== Reload daemon, enable service on startup, start service ==========\n\x1B[0m"
            sudo systemctl daemon-reload
            sudo systemctl enable $TUNNELNAME
            sudo systemctl start $TUNNELNAME
            break;;
        * ) echo invalid response;;
    esac

    done

    printf "\x1B[01;92m================== Done.  ==================\n\x1B[0m\n\n"
    printf "\x1B[01;92m================== Display tunnel status  ==================\n\x1B[0m\n\n"
    sudo systemctl status $TUNNEL
}

sshtunnel_activation
