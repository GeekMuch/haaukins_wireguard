#!/bin/bash

echo -en "\n[+] Haaukins VPN configuration\n\n\n"

is_user_root () { [ "$(id -u)" -eq 0 ]; }

if ! is_user_root; then
    echo '[X] Must be run as root!' >&2
    exit 1 # implicit, here it serves the purpose to be explicit for the reader
else


echo "[*] Install Wireguard"
sudo apt install wireguard

if [[ $? > 0 ]]; then
    echo -en "[X] Failed to install wireguard."
    exit
fi

echo -en "\n[*] Note that the config file must be in the same directory as the shellscript\n"
read -p "[+] Name of your config file(eg. conn_0.conf) from event page: " confFile

if [ -z "$confFile" ]; then
    echo -en "\n[X] No file found or empty\n"
else
    {   
        echo -en "\n[*] Copy to /etc/wirefuard\n"   
        sudo cp $confFile /etc/wireguard
    } || {
        echo -en "\n[X] Copy error!\n" 
        exit
    }
fi

FILE=/usr/local/bin/resolvconf

if [ -f "$FILE" ]; then
    echo -en "\n[*] File exists\n"    
else
    echo -en "\n[+] Creating link to resolvconf from resolvectl\n"
    ln -s /usr/bin/resolvectl /usr/local/bin/resolvconf
fi

echo -en "\n[*] Update and install resolvconf\n"

sudo apt-get update -y && sudo apt-get install resolvconf -y

if [[ $? > 0 ]]; then
    echo -en "[X] Failed to install resolvconf."
    exit
fi

echo -en "\n[*] Setting up DNS to 1.1.1.1\n"

CONFSTRIP="$(basename $confFile .conf)"

if sudo wg-quick up $CONFSTRIP 2>&1 | grep "tun"; then
    sudo sh -c "cd /etc/wireguard; sed -i \"/DNS = 1.1.1.1/d\" $confFile"
    sudo wg-quick up $CONFSTRIP
else
    echo -en "[X] Error setting up!"
    exit

fi

echo -en "\n[+] Running wireguard\n"
sudo wg
fi

is_user_root()