#### Outdoor temperature ####
# Icons are Nerd Font weather glyphs, so this item overrides the SF Pro default.
sketchybar --add item         weather right                            \
           --set weather      icon.font="$NERD_FONT:Regular:14.0"      \
                              label.font="$FONT:Light:14.0"            \
                              update_freq=900                          \
                              script="$PLUGIN_DIR/weather.sh"          \
                              click_script="$PLUGIN_DIR/weather.sh --refresh"    \
           --subscribe weather system_woke wifi_change
