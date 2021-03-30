#!/bin/bash

red=`tput setaf 9`
purple=`tput setaf 4`
green=`tput setaf 10`
yellow=`tput setaf 11`
reset=`tput sgr0`
checkmark="${green}✔${reset}"
cross="${red}✖${reset}"
printf "\033c"
echo "${purple}"
echo " _____               _   _ _      _____ _____ _____ _____ "
echo "|   __|___ ___ _ _ _| |_|_| |_   |     |     |_   _|_   _|"
echo "|  |  |  _| . | | | | '_| |  _|  | | | |  |  | | |   | |  "
echo "|_____|_| |___|_____|_,_|_|_|    |_|_|_|__  _| |_|   |_|  "
echo "                                          |__|            "
echo "${reset}"
printf "More info at: ${green}https://link.studionoorderlicht.nl/mqtt${reset}\n\n"

printf "Do you want to install/uninstall the watcher service? (i/u/Cancel): "
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
    printf "\n${checkmark} Made watcher.py executable"
    
    sudo cp service /etc/systemd/system/growkit-mqtt.service
    printf "\n${checkmark} Installed service"
    
    sudo systemctl daemon-reload
    printf "\n${checkmark} Reloaded systemctl\n"
    printf "\nDo you want to run the service at the boot of your system? (Y/n): "
    read answer
    
    if [ "$answer" != "${answer#[Nn]}" ] ;then
        printf "\n${cross} Skipping boot configuration"
    else
        sudo systemctl enable growkit-mqtt.service
        printf "\n${checkmark} Installed the watcher as startup service"
    fi
    
    sudo systemctl start growkit-mqtt.service
    printf "\n${checkmark} Watcher service started systemctl\n\n"

else
   printf "\n${cross} Canceling setup...\n\n"
fi
