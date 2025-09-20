#!/usr/bin/env bash

are_you_sure() {
    yn=$(echo -e "yes\nno" | fuzzel --dmenu --prompt "Are you sure? ")
    if [ "$yn" = "yes" ]; then
        eval "$1"
    else
        exit 0
    fi


}
choices="shutdown\nsuspend\nlock\nhibernate\nreboot"
chosen=$(echo -e "$choices"| fuzzel --dmenu --prompt "Power: ")


case "$chosen" in 
    shutdown) are_you_sure "shutdown -h now";;
    suspend) systemctl suspend && hyprlock;;
    lock) hyprlock;;
    hibernate) systemctl hibernate;;
    reboot) are_you_sure "reboot";;
esac
    
