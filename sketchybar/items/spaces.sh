#### AeroSpace workspaces ####
# AeroSpace has no macOS "spaces", so these are plain items rather than `space`
# items. A single hidden driver (spaces.driver) listens for the
# aerospace_workspace_change event that aerospace.toml fires via
# exec-on-workspace-change, and repaints all pills in one sketchybar call.

WORKSPACES=(1 2 3 4 5 6 7 8)

sketchybar --add event aerospace_workspace_change

for sid in "${WORKSPACES[@]}"; do
    sketchybar --add item space.$sid left                                \
               --set space.$sid icon="$sid"                             \
                                icon.font="$FONT:Light:15.0"            \
                                icon.padding_left=8                     \
                                icon.padding_right=8                    \
                                background.padding_left=5               \
                                background.padding_right=5              \
                                background.color=$HIGHLIGHT             \
                                background.corner_radius=5              \
                                background.height=22                    \
                                background.drawing=off                  \
                                label.drawing=off                       \
                                click_script="aerospace workspace $sid"
done

# Invisible driver: repaints every pill on workspace change.
sketchybar --add item spaces.driver left                            \
           --set spaces.driver drawing=off                          \
                               updates=on                           \
                               script="$PLUGIN_DIR/aerospace.sh"    \
           --subscribe spaces.driver aerospace_workspace_change      \
                                     display_change

sketchybar --add item space_separator left   \
           --set space_separator drawing=off \
                                 width=12
