#!/bin/bash
logMessage() {
    local param=$1
    local cfgFile="/var/log/system-bootstrap.log"
    touch $cfgFile
    local currentDate=$(date +'%Y-%m-%d_%H:%m:%S')
    local message="${currentDate} ${param}"
    echo $message
    echo $message >> $cfgFile
}

readCfg() {
    if [ ! -f system-init-cfg.txt ]; then
        echo "File not found!"
    else
        echo "Cfg file found!"
    fi

    file="system-init-cfg.txt"
    while IFS=: read -r f1 f2 f3 f4 f5 f6 f7 f8
    do
        repo=$f1
        ssh_key_path=$f2
        apps=$f3
        update_sys=$f4
        net_device=$f5
        ip_addrs=$f6
        hostname=$f7
        subnetmask=$f8
    done <"$file"

    while IFS= read key
    do
        ssh_key="$key"
    done <"$ssh_key_path"

    echo $repo
    echo $ssh_key
    echo $apps
    echo $update_sys
    echo $net_device
    echo $ip_addrs
    echo $hostname
    echo $subnetmask
}

readCfg