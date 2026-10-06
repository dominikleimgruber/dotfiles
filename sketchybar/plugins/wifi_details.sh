#!/usr/bin/env bash
# Fills the popup rows. Runs on the popup items' update_freq.

source "$HOME/.config/sketchybar/plugins/wifi.sh"

case "$NAME" in
  wifi.ssid)
    if SSID="$(net_ssid)"; then
      sketchybar --set wifi.ssid label="$SSID"
    elif [ "$(net_iface)" = "en0" ]; then
      # See net_ssid(): needs Location permission to read the name.
      sketchybar --set wifi.ssid label="Wi-Fi (name unavailable)"
    else
      sketchybar --set wifi.ssid label="Ethernet ($(net_iface))"
    fi
    ;;
  wifi.ip)
    sketchybar --set wifi.ip label="$(net_ip 2>/dev/null || echo 'no address')"
    ;;
esac
