#!/bin/bash
choice=$(printf "Lock\nLogout\nSuspend\nShutdown\nReboot" | rofi -dmenu -p "Power")
case "$choice" in
    Lock) hyprlock ;;
    Logout) hyprctl dispatch exit ;;
    Suspend) systemctl suspend ;;
    Shutdown) systemctl poweroff ;;
    Reboot) systemctl reboot ;;
esac
