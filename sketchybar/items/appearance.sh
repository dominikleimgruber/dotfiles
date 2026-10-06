#### Light/dark toggle ####
sketchybar --add item         appearance right                            \
           --set appearance   script="$PLUGIN_DIR/appearance.sh"          \
                              click_script="$PLUGIN_DIR/appearance_click.sh" \
                              label.drawing=off                           \
                              update_freq=5
