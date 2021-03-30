#!/bin/bash

red=`tput setaf 9`
purple=`tput setaf 4`
green=`tput setaf 10`
yellow=`tput setaf 11`
reset=`tput sgr0`
checkmark="${green}✔${reset}"
cross="${red}✖${reset}"

echo "${purple}"
echo "                                                          "
echo " _____               _   _ _      _____ _____ _____ _____ "
echo "|   __|___ ___ _ _ _| |_|_| |_   |     |     |_   _|_   _|"
echo "|  |  |  _| . | | | | '_| |  _|  | | | |  |  | | |   | |  "
echo "|_____|_| |___|_____|_,_|_|_|    |_|_|_|__  _| |_|   |_|  "
echo "                                          |__|            "
echo "${reset}"

echo "Do you want to install/uninstall the watcher service? (i/u/Cancel)"
read answer

if [ "$answer" != "${answer#[Uu]}" ] ;then

    sudo systemctl stop growkit-mqtt.service
    echo "${checkmark} Stopped service if running"
    sudo systemctl disable growkit-mqtt.service
    echo "${checkmark} Disabled service from systemctl"
    sudo systemctl daemon-reload
    sudo systemctl reset-failed
    echo "${checkmark} Reloaded systemctl"
   
elif [ "$answer" != "${answer#[Iiy]}" ] ;then
    
    sudo chmod +x watcher.py
    echo "${checkmark} Made watcher.py executable"
    
    sudo cp service /etc/systemd/system/growkit-mqtt.service
    echo "${checkmark} Installed service"
    
    sudo systemctl daemon-reload
    echo "${checkmark} Reloaded systemctl"
    
    echo "Do you want to run the service at the boot of your system? (Y/n)"
    read answer
    
    if [ "$answer" != "${answer#[Nn]}" ] ;then
        echo "${cross} Skipping boot configuration"
    else
        sudo systemctl enable growkit-mqtt.service
        echo "${checkmark} Installed the watcher as startup service"
    fi
    
    sudo systemctl start growkit-mqtt.service
    echo "${checkmark} Watcher service started systemctl"

else
   echo "${cross} Canceling setup..."
fi
