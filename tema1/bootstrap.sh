#!/bin/bash
$repo=$1
$ssh_key=$2
$apps=$3
$update_sys=$4
$net_device=$5
$ip_addr=$6
$hostname=$7
$subnetmask=$8

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
    if [[ updateSysProg -eq 1]]; then
        logMessage "Updating system programs..."
        sudo yum install yum-utils
        sudo package-cleanup --oldkernels --count=2
        sudo yum update
    fi
}

installApps() {
    logMessage "Installing ${apps}"
    sudo yum install $apps
    logMessage "${apps} are now installed."
}

setupNetworkAdapter() {
    logMessage "Configuring the host-only adaptor"
    adapterIsUp=$(nmcli -t -f NAME conn show --active | grep $net_device | wc -l)

    if [[ $adapterIsUp -gt 0 ]]; then
        logMessage "Device $net_device is up"
    else
        logMessage "Device $net_device is down"
        logMessage "Bringing device $connet_devicen up..."
        nmcli conn up $net_device
        if [[ $? -eq 0 ]]; then
            logMessage "Device $net_device is now up."
            adapterIsUp=1
        else
            logMessage "ERROR: Device $net_device didn't come up."
            adapterIsUp=0
        fi
    fi
}

### main script
welcome
updateSysProg
installApps
setupNetworkAdapter

if [[ $adapterIsUp -gt 0 ]]; then
	ip=$(ip address show enp0s8 | grep "inet " | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | cut -d ' ' -f 2)
	eval "$(ssh-agent -s)"
	statusCode=$(ssh-add $ssh_key)
	if [[ $statusCode -eq 0 ]]; then
		logMessage "SSH key added."
		logMessage "Now you can ssh to $ip_addr without a password."
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
