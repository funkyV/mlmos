#!/bin/bash
source
### funk
logMessage() {
    local param=$1
    local cfgFile="/var/log/system-bootstrap.log"
    touch $cfgFile
    local currentDate=$(date +'%Y-%m-%d_%H:%m:%S')
    local message="${currentDate} ${param}"
    echo $message
    echo $message >> $cfgFile
}

welcome() {
    logMessage "Welcome to Vlad Minea's Bootstrap"
}

updateSysProg() {
    logMessage "Updating system programs..."
    sudo yum install yum-utils
    sudo package-cleanup --oldkernels --count=2
    sudo yum update
}

installGit() {
    logMessage "Installing git..."
    sudo yum install git
    logMessage "git is now installed."
}

setupNetworkAdapter() {
    logMessage "Configuring the host-only adaptor"
    local conn="enp0s8"
    adapterIsUp=$(nmcli -t -f NAME conn show --active | grep $conn | wc -l)

    if [[ $adapterIsUp -gt 0 ]]; then
        logMessage "Device $conn is up"
    else
        logMessage "Device $conn is down"
        logMessage "Bringing device $conn up..."
        nmcli conn up $conn
        if [[ $? -eq 0 ]]; then
            logMessage "Device $conn is now up."
            adapterIsUp=1
        else
            logMessage "ERROR: Device $conn didn't come up."
            adapterIsUp=0
        fi
    fi
}



### main script
readCfg
welcome
updateSysProg
installGit
setupNetworkAdapter

if [[ $adapterIsUp -gt 0 ]]; then
	logMessage "Please enter your ssh key:"
	ip=$(ip address show enp0s8 | grep "inet " | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | cut -d ' ' -f 2)
	read sshkey
	eval "$(ssh-agent -s)"
	statusCode=$(ssh-add $sshkey)
	if [[ $statusCode -eq 0 ]]; then
		logMessage "SSH key added."
		logMessage "Now you can ssh to $ip without a password."
        local selinuxCfgFile='/etc/selinux/config'
        sudo sed -i 's/SELINUX=enforcing/SELINUX=disabled/' $selinuxCfgFile
        sudo sed -i 's/SELINUX=permissive/SELINUX=disabled/' $selinuxCfgFile
        sudo setenforce 0
	elif [[ $statusCode -eq 1 ]]; then
		logMessage "ERROR: Specified command failed."
    elif [[ $statusCode -eq 2 ]]; then
        logMessage "ERROR: ssh-add was unable to contact the authentication agen."
	fi
fi
