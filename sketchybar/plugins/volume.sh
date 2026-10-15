#!/usr/bin/env bash
# Drives the audio item: device-aware icon, volume label, animated slider and a
# popup for switching output device.
#
# The device category is cached, because classifying it needs system_profiler
# (~0.2s) and volume_change fires rapidly while a volume key is held. The fast
# path (volume_change) only reads that cache; the slow path (update_freq,
# system_woke, a device switch) refreshes it.

source "$HOME/.config/sketchybar/icons.sh"
source "$HOME/.config/sketchybar/colors.sh"

PLUGINS="$HOME/.config/sketchybar/plugins"
CACHE_DIR="${TMPDIR:-/tmp}/sketchybar-audio"
CAT_FILE="$CACHE_DIR/category"
DEV_FILE="$CACHE_DIR/device"
SLIDER_WIDTH=100
mkdir -p "$CACHE_DIR"

refresh_device() {
  local out
  out="$("$PLUGINS/audio_device.py" 2>/dev/null)" || return 1
  [ -z "$out" ] && return 1
  printf '%s' "${out%%$'\t'*}" > "$CAT_FILE"
  printf '%s' "${out#*$'\t'}"  > "$DEV_FILE"
}

category() { cat "$CAT_FILE" 2>/dev/null || echo speakers; }
device_name() { cat "$DEV_FILE" 2>/dev/null || echo "Output"; }

# Volume as an integer 0-100, and whether output is muted.
current_volume() {
  osascript -e 'output volume of (get volume settings)' 2>/dev/null || echo 0
}
is_muted() {
  [ "$(osascript -e 'output muted of (get volume settings)' 2>/dev/null)" = "true" ]
}

icon_for() {
  local cat="$1" vol="$2"
  if [ "$vol" -le 0 ] 2>/dev/null; then echo "$VOLUME_MUTED"; return; fi
  case "$cat" in
    airpods)    echo "$AUDIO_AIRPODS" ;;
    headphones) echo "$AUDIO_HEADPHONES" ;;
    display)    echo "$AUDIO_DISPLAY" ;;
    *)  # Built-in / USB / virtual output: let the glyph carry the level too.
        if   [ "$vol" -ge 60 ]; then echo "$VOLUME_HIGH"
        elif [ "$vol" -ge 25 ]; then echo "$VOLUME_MEDIUM"
        else                         echo "$VOLUME_LOW"
        fi ;;
  esac
}

paint() {
  local vol="$1" cat icon
  cat="$(category)"
  if is_muted; then vol=0; fi
  icon="$(icon_for "$cat" "$vol")"
  sketchybar --set audio.icon icon="$icon" \
                              icon.color="$([ "$vol" -le 0 ] && echo "$GREY" || echo "$WHITE")" \
                              label="${vol}%" \
             --set audio.slider slider.percentage="$vol"
}

# Briefly reveal the slider, then collapse it again if nothing changed meanwhile.
flash_slider() {
  local vol="$1" width
  width="$(sketchybar --query audio.slider | python3 -c 'import sys,json;print(json.load(sys.stdin)["slider"]["width"])' 2>/dev/null || echo 0)"
  if [ "$width" = "0" ]; then
    # Padding is added only while open; collapsed it must be 0 or it leaves a gap.
    sketchybar --animate tanh 30 --set audio.slider slider.width=$SLIDER_WIDTH \
                                                     background.padding_left=6   \
                                                     background.padding_right=6
  fi
  sleep 2
  local now
  now="$(sketchybar --query audio.slider | python3 -c 'import sys,json;print(json.load(sys.stdin)["slider"]["percentage"])' 2>/dev/null || echo -1)"
  if [ "$now" = "$vol" ]; then
    sketchybar --animate tanh 30 --set audio.slider slider.width=0 \
                                                     background.padding_left=0 \
                                                     background.padding_right=0
  fi
}

# Rebuild the popup list of output devices, marking the active one.
build_device_popup() {
  command -v SwitchAudioSource >/dev/null 2>&1 || return 0
  local current args=() i=0
  current="$(device_name)"
  args+=(--remove '/audio.device\..*/')
  while IFS= read -r dev; do
    [ -z "$dev" ] && continue
    local id="audio.device.$i"
    args+=(--add item "$id" popup.audio.icon
           --set "$id" label="$dev"
                       icon.drawing=off
                       label.color="$([ "$dev" = "$current" ] && echo "$BLUE" || echo "$WHITE")"
                       click_script="SwitchAudioSource -t output -s \"$dev\"; \
                                     sketchybar --set audio.icon popup.drawing=off; \
                                     \"$PLUGINS/volume.sh\" device_changed")
    i=$((i+1))
  done < <(SwitchAudioSource -a -t output 2>/dev/null)
  ((${#args[@]})) && sketchybar "${args[@]}"
}

case "${SENDER:-${1:-}}" in
  volume_change)
    # $INFO is the new volume; no device lookup on this path.
    paint "${INFO:-$(current_volume)}"
    flash_slider "${INFO:-0}"
    ;;
  mouse.clicked)
    # Clicking the slider seeks to that position.
    if [ -n "${PERCENTAGE:-}" ]; then
      osascript -e "set volume output volume $PERCENTAGE" 2>/dev/null
      paint "$PERCENTAGE"
    fi
    ;;
  toggle_popup)
    refresh_device
    build_device_popup
    sketchybar --set audio.icon popup.drawing=toggle
    ;;
  device_changed)
    sleep 0.4           # let CoreAudio settle on the new default
    refresh_device
    paint "$(current_volume)"
    ;;
  *)  # routine tick, forced, system_woke
    refresh_device
    paint "$(current_volume)"
    ;;
esac
