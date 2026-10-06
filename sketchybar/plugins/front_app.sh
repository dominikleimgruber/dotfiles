#!/usr/bin/env bash
# $INFO carries the app name on front_app_switched. On the initial paint there is
# no event yet, so fall back to querying the frontmost app directly.

APP="$INFO"

if [ -z "$APP" ]; then
  APP="$(lsappinfo info -only name "$(lsappinfo front)" 2>/dev/null \
         | sed -n 's/^"\([^"]*\)".*/\1/p')"
fi

sketchybar --set "$NAME" label="$APP"
