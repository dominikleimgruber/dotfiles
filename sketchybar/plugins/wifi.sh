#!/usr/bin/env bash
# Shared network helpers. Sourced by items/wifi.sh and run as the item script.

source "$HOME/.config/sketchybar/icons.sh"
source "$HOME/.config/sketchybar/colors.sh"

# Interface carrying the default route.
net_iface() {
  route -n get default 2>/dev/null | awk '/interface:/ {print $2; exit}'
}

net_ip() {
  ipconfig getifaddr "$(net_iface)" 2>/dev/null
}

# macOS 14+ removed the `airport` binary, and every remaining SSID source is
# redacted unless the calling process holds Location Services permission. We try
# the surviving sources and treat a redacted/empty answer as "unknown".
net_ssid() {
  local ssid
  ssid="$(ipconfig getsummary "$(net_iface)" 2>/dev/null \
          | awk -F' SSID : ' '/ SSID : / {print $2; exit}')"
  if [ -z "$ssid" ]; then
    ssid="$(networksetup -getairportnetwork en0 2>/dev/null \
            | sed -n 's/^Current Wi-Fi Network: //p')"
  fi
  case "$ssid" in
    ''|'<redacted>'|*'not associated'*) return 1 ;;
  esac
  printf '%s' "$ssid"
}

wifi_powered() {
  networksetup -getairportpower en0 2>/dev/null | grep -q ': On$'
}

POPUP_OFF="sketchybar --set wifi.control popup.drawing=off"
POPUP_CLICK_SCRIPT="sketchybar --set \$NAME popup.drawing=toggle"

# When invoked as an item script (not merely sourced), refresh the icon.
if [ -n "$NAME" ]; then
  IFACE="$(net_iface)"
  if [ -z "$IFACE" ]; then
    sketchybar --set wifi.control icon="$WIFI_OFF_ICN" icon.color="$RED"
  elif [ "$IFACE" = "en0" ]; then
    if wifi_powered; then
      sketchybar --set wifi.control icon="$WIFI_ICN" icon.color="$WHITE"
    else
      sketchybar --set wifi.control icon="$WIFI_OFF_ICN" icon.color="$RED"
    fi
  else
    # Dock / Thunderbolt ethernet.
    sketchybar --set wifi.control icon="$ETHERNET_ICN" icon.color="$WHITE"
  fi
fi
