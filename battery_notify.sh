#!/bin/bash

#default thresholds and options

FULL=95
THRESHOLD=30
LOW=20
CRITICAL=10
SUSPEND_ON_CRITICAL=false
# LOGFILE="$HOME/log/battery-alert.log"
CRITICAL_SOUND='/usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga'

play_critical_sound() {
  bash $HOME/piper/scripts/speak.sh "Battery is in critical condition. Please connect to charger. I repeat, battery in critical condition." >/dev/null 2>&1 &
  paplay "$CRITICAL_SOUND" >/dev/null 2>&1
}

#function to auto SUSPEND_ON_CRITICAL
suspend_on_critical() {
  if $SUSPEND_ON_CRITICAL; then
    STATUS=$(cat /sys/class/power_supply/BAT0/status)
    if [[ "$STATUS" != "Charging" ]]; then
      systemctl suspend
    fi
  fi
}

# main
while true; do
  BATTERY_LEVEL=$(cat /sys/class/power_supply/BAT0/capacity)
  STATUS=$(cat /sys/class/power_supply/BAT0/status)
  echo "${STATUS} ${BATTERY_LEVEL}"
  if [[ "$BATTERY_LEVEL" -ge "$FULL" ]]; then
    if [[ "$STATUS" == "Charging" ]]; then
      notify-send -i battery-full "Battery Full" "You current battery is ${BATTERY_LEVEL}%.\nUnplug the charger."
    fi
    sleep 50m
    continue
  fi
  if [[ "$STATUS" != "Charging" ]]; then
    if [[ "$BATTERY_LEVEL" -le "$CRITICAL" ]]; then
      notify-send -u critical -i battery-missing "Battery critical" "Connect to the charger.\nBattery level is ${BATTERY_LEVEL}% ."
      play_critical_sound
      sleep 60s
      suspend_on_critical
    elif [[ "$BATTERY_LEVEL" -le "$LOW" ]]; then
      notify-send -u normal -i battery-caution "Battery low" "Connect to the charger.\nBattery level is ${BATTERY_LEVEL}%"
      sleep 5m
    elif [[ "$BATTERY_LEVEL" -lt "$THRESHOLD" ]]; then
      notify-send -u normal -i battery-caution "Battery warning" "Battery is less than ${BATTERY_LEVEL}%\nConnect to the charger."
      sleep 10m
    fi
  fi
  sleep 10s
done
