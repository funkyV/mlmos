#!/bin/bash
### funk
logMessage() {
    local param=$1
    local cfgFile="/var/log/system-bootstrap.log"
    touch $cfgFile
    echo $param
    echo $param >> $cfgFile
}

welcome() {
    echo "Welcome to Vlad Minea's Bootstrap"
}

updateSysProg() {
    echo "Updating system programs..."
    sudo yum install yum-utils
    sudo package-cleanup --oldkernels --count=2
    sudo yum update
}

installGit() {
    echo "Installing git..."
    sudo yum install git
    echo "git is now installed."
}

setupNetworkAdapter() {
    echo "Configuring the host-only adaptor"
    local conn="enp0s8"
    adapterIsUp=$(nmcli -t -f NAME conn show --active | grep $conn | wc -l)

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
}

### main script

welcome
updateSysProg
installGit
setupNetworkAdapter
echo $adapterIsUp
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

