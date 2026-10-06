#!/usr/bin/env bash
# Repaints every workspace pill in a single sketchybar call.
#
# All eight numbers stay visible at all times. Three tiers tell them apart:
#   focused          -> pill background + bright text
#   has windows      -> no pill, bright text
#   empty            -> no pill, dimmed text

source "$HOME/.config/sketchybar/colors.sh"

AEROSPACE="$(command -v aerospace || echo /opt/homebrew/bin/aerospace)"

# exec-on-workspace-change hands us FOCUSED_WORKSPACE; fall back to a query
# for the initial paint and for display_change events.
FOCUSED="${FOCUSED_WORKSPACE:-$("$AEROSPACE" list-workspaces --focused 2>/dev/null)}"

# Workspaces that currently hold at least one window.
OCCUPIED=" $("$AEROSPACE" list-workspaces --monitor all --empty no 2>/dev/null | tr '\n' ' ')"

args=()
for sid in 1 2 3 4 5 6 7 8; do
    if [ "$sid" = "$FOCUSED" ]; then
        args+=(--set "space.$sid" drawing=on            \
                                  background.drawing=on \
                                  icon.color="$WHITE")
    elif [[ "$OCCUPIED" == *" $sid "* ]]; then
        args+=(--set "space.$sid" drawing=on             \
                                  background.drawing=off \
                                  icon.color="$WHITE")
    else
        args+=(--set "space.$sid" drawing=on             \
                                  background.drawing=off \
                                  icon.color="$DIM")
    fi
done

sketchybar "${args[@]}"
