install() {
    printf "\x1B[01;93m========== Updating system ==========\n\x1B[0m"
    sudo apt update
    sudo apt upgrade -y

    printf "\x1B[01;93m========== Install HaProxy 2.6 and dependencies ==========\n\x1B[0m"
    sudo apt install --no-install-recommends software-properties-common
    sudo add-apt-repository ppa:vbernat/haproxy-2.6 -y
    sudo apt update
    sudo apt install haproxy=2.6.\* -y

}
# Actually do the install. Put in function and run at end to prevent parcial download and execution.
install
