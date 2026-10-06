#!/usr/bin/env bash

osascript -e 'tell app "System Events" to tell appearance preferences to set dark mode to not dark mode'

# Absolute path: the reference's relative `./darkmode.sh` only worked by accident.
exec "$HOME/.config/sketchybar/plugins/appearance.sh"
