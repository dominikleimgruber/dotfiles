#### Network, with a click-through popup ####
source "$PLUGIN_DIR/wifi.sh"

sketchybar --add item         wifi.control right                     \
           --set wifi.control icon=$WIFI_ICN                         \
                              label.drawing=off                      \
                              update_freq=10                         \
                              script="$PLUGIN_DIR/wifi.sh"           \
                              click_script="$POPUP_CLICK_SCRIPT"     \
                              popup.background.color=$POPUP_BG       \
                              popup.blur_radius=50                   \
                              popup.background.corner_radius=5       \
                              popup.align=right                      \
           --subscribe wifi.control wifi_change system_woke          \
                                                                     \
           --add item         wifi.ssid popup.wifi.control           \
           --set wifi.ssid    icon=$NETWORK_ICN                      \
                              label="..."                            \
                              update_freq=10                         \
                              script="$PLUGIN_DIR/wifi_details.sh"   \
                                                                     \
           --add item         wifi.ip popup.wifi.control             \
           --set wifi.ip      icon=$IP_ICN                           \
                              label="..."                            \
                              update_freq=10                         \
                              script="$PLUGIN_DIR/wifi_details.sh"
