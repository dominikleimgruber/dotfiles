#### Audio: device-aware icon, volume label, slider and output-device popup ####
# The icon glyphs are Nerd Font (nf-md-*), so this item overrides the SF Pro default.
#
# The slider's own icon/label/background padding is zeroed: a slider with
# slider.width=0 still occupies its padding, which left a visible gap between the
# audio and network items while collapsed. plugins/volume.sh adds breathing room
# back via background.padding_* only while the slider is open.

sketchybar --add item         audio.icon right                               \
           --set audio.icon   icon.font="$NERD_FONT:Regular:16.0"            \
                              label.font="$FONT:Light:14.0"                  \
                              icon.padding_left=6                           \
                              label.padding_right=6                         \
                              update_freq=5                                 \
                              script="$PLUGIN_DIR/volume.sh"                \
                              click_script="$PLUGIN_DIR/volume.sh toggle_popup" \
                              popup.background.color=$POPUP_BG              \
                              popup.blur_radius=50                          \
                              popup.background.corner_radius=5              \
                              popup.align=right                             \
           --subscribe audio.icon volume_change system_woke                  \
                                                                             \
           --add slider       audio.slider right 0                           \
           --set audio.slider script="$PLUGIN_DIR/volume.sh"                \
                              slider.highlight_color=$BLUE                  \
                              slider.background.height=6                    \
                              slider.background.corner_radius=3             \
                              slider.background.color=$HIGHLIGHT            \
                              slider.knob.drawing=off                       \
                              slider.width=0                                \
                              icon.drawing=off                              \
                              label.drawing=off                             \
                              icon.padding_left=0                           \
                              icon.padding_right=0                          \
                              label.padding_left=0                          \
                              label.padding_right=0                         \
                              background.padding_left=0                     \
                              background.padding_right=0                    \
           --subscribe audio.slider volume_change mouse.clicked
