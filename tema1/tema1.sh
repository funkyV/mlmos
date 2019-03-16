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
        logMessage "File not found!"
        logMessage "File created"
        echo "github.com/funkyV/mlmos.git:pub_key.txt:git python docker:1:enp0s8:192.168.99.101:my-centos-vm.locallan:255.255.255.0
        " >> system-init-cfg.txt
        chmod 777 system-init-cfg.txt
    else
        logMessage "Cfg file found!"
        chmod 777 system-init-cfg.txt
    fi

    file="home/vminea/system-init-cfg.txt"
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

    # echo $repo
    # echo $ssh_key
    # echo $apps
    # echo $update_sys
    # echo $net_device
    # echo $ip_addrs
    # echo $hostname
    # echo $subnetmask
}
# hostnamectl set-hostname $hostname
readCfg
git clone $repo /home/vminea/mlmos
bash /home/vminea/mlmos/tema1/bootstrap.sh $repo $ssh_key $apps $update_sys $net_device $ip_addrs $hostname $subnetmask