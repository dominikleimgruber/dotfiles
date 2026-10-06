#!/usr/bin/env bash

source "$HOME/.config/sketchybar/icons.sh"
source "$HOME/.config/sketchybar/colors.sh"

BATT="$(pmset -g batt)"
PERCENTAGE="$(echo "$BATT" | grep -Eo '[0-9]+%' | head -1 | tr -d '%')"
CHARGING="$(echo "$BATT" | grep 'AC Power')"

# Desktop / no battery reported: hide the item rather than drawing a blank.
if [ -z "$PERCENTAGE" ]; then
  sketchybar --set "$NAME" drawing=off
  exit 0
fi

COLOR=$WHITE
case "$PERCENTAGE" in
  100|9[0-9])  ICON=$BATTERY_100 ;;
  [6-8][0-9])  ICON=$BATTERY_75  ;;
  [3-5][0-9])  ICON=$BATTERY_50  ;;
  [1-2][0-9])  ICON=$BATTERY_25; COLOR=$YELLOW ;;
  *)           ICON=$BATTERY_0;  COLOR=$RED    ;;
esac

if [ -n "$CHARGING" ]; then
  ICON=$BATTERY_CHARGING
  COLOR=$GREEN
fi

sketchybar --set "$NAME" drawing=on        \
                         icon="$ICON"      \
                         icon.color="$COLOR" \
                         label="${PERCENTAGE}%"
