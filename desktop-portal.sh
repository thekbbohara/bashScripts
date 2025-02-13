#!/usr/bin/env bash
# This script is likely used to fix issues with desktop portals (like screenshot tools, screen sharing, and file pickers) when using Hyprland. Restarting these processes ensures that applications relying on xdg-desktop-portal work correctly after a crash or update.

# echo "Restarting xdg-desktop-portal services..."

# Small delay to ensure stability
sleep 1

# Function to safely kill a process if running
kill_process() {
    if pgrep -x "$1" >/dev/null; then
        # echo "Stopping $1..."
        killall -e "$1"
    else
        echo "$1 is not running, skipping."
    fi
}

# Kill existing processes if they are running
kill_process "xdg-desktop-portal-hyprland"
kill_process "xdg-desktop-portal"

# Restart Hyprland-specific portal
# echo "Starting xdg-desktop-portal-hyprland..."
/usr/lib/xdg-desktop-portal-hyprland & disown

# Wait a bit for Hyprland portal to start
sleep 2

# Restart the general xdg-desktop-portal
# echo "Starting xdg-desktop-portal..."
/usr/lib/xdg-desktop-portal & disown

# echo "xdg-desktop-portal services restarted successfully!"

