#### Focused application ####
sketchybar --add item front_app left                             \
           --set front_app script="$PLUGIN_DIR/front_app.sh"     \
                           icon.drawing=off                      \
                           label.font="$FONT:Semibold:15.0"      \
           --subscribe front_app front_app_switched

# Paint once now; front_app_switched only fires on subsequent switches.
NAME=front_app "$PLUGIN_DIR/front_app.sh" >/dev/null 2>&1 || true
