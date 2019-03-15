#!/bin/bash

log() {

}

welcome() {
    echo "Welcome to Vlad Minea's Bootstrap"
}

updateSysProg() {
    echo "Updating system programs..."
    su --command="yum update"
}

installGit() {
    echo "Installing git..."
    # if hash git 2>/dev/null; then
    # 	echo "git is already installed"
    # else
    # 	echo "git is not installed"
    # 	echo "git will be installed now"
    # 	su -c "yum install git"
    # fi
}

setupNetworkAdapter() {
    echo "Configuring the host-only adaptor"
    local conn="enp0s8"
    local adapterIsUp=$(nmcli -t -f NAME conn show --active | grep $conn | wc -l)

    if [[ $adapterIsUp -gt 0 ]]; then
        echo "Device $conn is up"
    else
        echo "Device $conn is down"
        echo "Bringing device $conn up..."
        nmcli conn up $conn
        if [[ $? -eq 0 ]]; then
            echo "Device $conn is now up."
            adapterIsUp=1
        else
            echo "ERROR: Device $conn didn't come up."
            adapterIsUp=0
        fi
    fi

    return adapterIsUp
}

adapterIsUp = setupNetworkAdapter()

if [[ $adapterIsUp -gt 0 ]]; then
	echo "Please enter your ssh key:"
	ip=$(ip address show enp0s8 | grep "inet " | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | cut -d ' ' -f 2)
	read sshkey
	eval "$(ssh-agent -s)"
	statusCode=$(ssh-add $sshkey)
	if [[ $statusCode -eq 0 ]]; then
		echo "SSH key added."
		echo "Now you can ssh to $ip without a password."
	elif [[ $statusCode -eq 1 ]]; then
		echo "ERROR: Specified command failed."
    elif [[ $statusCode -eq 2 ]]; then
        echo "ERROR: ssh-add was unable to contact the authentication agen."
	fi
fi