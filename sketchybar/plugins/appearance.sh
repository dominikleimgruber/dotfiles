#!/usr/bin/env bash
# Shows the appearance you can switch TO: sun while dark, moon while light.

source "$HOME/.config/sketchybar/icons.sh"

if [ "$(defaults read -g AppleInterfaceStyle 2>/dev/null)" = "Dark" ]; then
  sketchybar --set appearance icon="$SUN_ICN"
else
  sketchybar --set appearance icon="$MOON_ICN"
fi
