
#!/bin/bash

# Default thresholds and options
FULL=95
THRESHOLD=30
LOW=20
CRITICAL=10
SUSPEND_ON_CRITICAL=false
CRITICAL_SOUND='/usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga'

# Arrays for sarcastic messages
CRITICAL_MSGS=(
  "Critical battery alert! I’d love to keep working, but I’m about to pass out. Either plug me in or start writing your goodbyes."
  "Yo! Your battery is gasping for its last breath at ${BATTERY_LEVEL}%. Unless you're doing a speedrun to shutdown, find a charger. Now."
  "Warning! Your battery is so low, it’s considering an early retirement. Please, for the love of all that’s digital, plug it in."
  "Well well well… ${BATTERY_LEVEL}% battery. What’s the plan? Hope and prayers? Because I don’t think that’s gonna charge me."
  "Oh great, battery critical. I guess we’re playing ‘How fast can I find a charger before my laptop shuts down?’ Good luck."
  "Your battery is so low it’s practically begging for mercy. This is your final warning before we enter the abyss of darkness."
  "No charger? No problem. Just embrace the void. The laptop gods have spoken, and they demand power!"
  "This is not a drill! Your battery is lower than my motivation on a Monday morning. Charge me before it’s too late!"
)

FULL_MSGS=(
"Battery full. Please remove the charger. I repeat, If you don't have money to change the battery, remove the damn charger."
)

# Function to pick a random message from an array
random_message() {
  local messages=("$@")
  echo "${messages[RANDOM % ${#messages[@]}]}"
}


# Play critical battery warning with sarcasm
play_critical_sound() {
  local msg=$(random_message "${CRITICAL_MSGS[@]}")
  notify-send -u critical -i battery-missing "⚠️ Battery Critical" "$msg"
  paplay "$CRITICAL_SOUND" >/dev/null 2>&1 &
  sh $HOME/bashScripts/speak.sh "$msg" &
}

# Play sarcastic battery full notification
play_batteryfull_sound() {
  local msg=$(random_message "${FULL_MSGS[@]}")
  notify-send -i battery-full "🔋 Battery Full" "$msg"
  sh $HOME/bashScripts/speak.sh "$msg"
}

# Function to auto suspend when battery is critical
suspend_on_critical() {
  if $SUSPEND_ON_CRITICAL; then
    STATUS=$(cat /sys/class/power_supply/BAT0/status)
    if [[ "$STATUS" != "Charging" ]]; then
      systemctl suspend
    fi
  fi
}

# Main loop
while true; do
  BATTERY_LEVEL=$(cat /sys/class/power_supply/BAT0/capacity)
  STATUS=$(cat /sys/class/power_supply/BAT0/status)
  echo "${STATUS} ${BATTERY_LEVEL}"

  if [[ "$BATTERY_LEVEL" -ge "$FULL" ]]; then
    if [[ "$STATUS" == "Charging" ]]; then
      play_batteryfull_sound
    fi
    sleep 50m
    continue
  fi

  if [[ "$STATUS" != "Charging" ]]; then
    if [[ "$BATTERY_LEVEL" -le "$CRITICAL" ]]; then
      play_critical_sound
      sleep 60s
      suspend_on_critical
    elif [[ "$BATTERY_LEVEL" -le "$LOW" ]]; then
      notify-send -u normal -i battery-caution "Battery Low" "Your battery is at ${BATTERY_LEVEL}%. Either charge me, or prepare for an abrupt shutdown."
      sleep 5m
    elif [[ "$BATTERY_LEVEL" -lt "$THRESHOLD" ]]; then
      notify-send -u normal -i battery-caution "Battery Warning" "Battery is at ${BATTERY_LEVEL}%. Maybe… just maybe… plug in the charger before it’s too late?"
      sleep 10m
    fi
  fi

  sleep 10s
done

