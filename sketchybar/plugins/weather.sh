#!/usr/bin/env bash
# Current outdoor temperature for wherever this machine is right now.
#
# Location is resolved at runtime, so the bar follows you instead of pinning one
# city: CoreLocation (real device location) when permission allows, otherwise
# public-IP geolocation, which only locates your ISP's egress point.
# Weather itself comes from Open-Meteo (no key, returns a WMO code + is_day,
# which is what drives the icon).

source "$HOME/.config/sketchybar/icons.sh"
source "$HOME/.config/sketchybar/colors.sh"

CACHE_DIR="${TMPDIR:-/tmp}/sketchybar-weather"
GEO_CACHE="$CACHE_DIR/geo"
LAST_GOOD="$CACHE_DIR/last"
SHORTEN="$HOME/.config/sketchybar/plugins/city_code.py"
GEO_TTL=1800   # re-check location every 30 min
mkdir -p "$CACHE_DIR"

# Clicking the item passes --refresh: drop the cached location so a fresh fix is
# taken immediately (useful right after granting Location permission, or when
# you have just arrived somewhere).
[ "$1" = "--refresh" ] && rm -f "$GEO_CACHE"

# --- location -------------------------------------------------------------
# Preferred: CoreLocation (the real device location, via CoreLocationCLI).
# Fallback:  public-IP geolocation, which only resolves to the ISP's egress
#            point and can be tens of kilometres off.

# No timeout(1) on macOS, so bound the call by hand: CoreLocation blocks
# waiting for a fix when permission is missing.
run_with_timeout() {
  local secs="$1"; shift
  "$@" &
  local pid=$!
  ( sleep "$secs"; kill -9 "$pid" 2>/dev/null ) >/dev/null 2>&1 &
  local killer=$!
  wait "$pid" 2>/dev/null
  local rc=$?
  kill "$killer" 2>/dev/null
  return $rc
}

geo=""
if [ -f "$GEO_CACHE" ] && [ $(( $(date +%s) - $(stat -f %m "$GEO_CACHE") )) -lt $GEO_TTL ]; then
  geo="$(cat "$GEO_CACHE")"
fi

if [ -z "$geo" ] && command -v CoreLocationCLI >/dev/null 2>&1; then
  # --json rather than -format: the format path prints as soon as it has a fix,
  # before reverse geocoding resolves, so %locality comes back empty. --json
  # waits for the placemark and carries the city.
  raw="$(run_with_timeout 12 CoreLocationCLI --json 2>/dev/null \
         | python3 -c '
import sys, json
try:
    d = json.loads(sys.stdin.readline())
    print(d["latitude"], d["longitude"], d.get("locality") or "")
except Exception:
    raise SystemExit(1)
' 2>/dev/null)"
  # $SHORTEN re-validates the coordinates, so a stray error line cannot be cached.
  [ -n "$raw" ] && geo="$(printf '%s' "$raw" | "$SHORTEN")"
fi

if [ -z "$geo" ]; then
  geo="$(curl -s --max-time 6 'http://ip-api.com/json/?fields=status,lat,lon,city' \
         | python3 -c '
import sys, json
try:
    d = json.load(sys.stdin)
except Exception:
    raise SystemExit(1)
if d.get("status") != "success":
    raise SystemExit(1)
print(d["lat"], d["lon"], d.get("city", ""))
' 2>/dev/null | "$SHORTEN")"
fi

[ -n "$geo" ] && printf '%s' "$geo" > "$GEO_CACHE"

# Fall back to the last known location rather than blanking the bar.
[ -z "$geo" ] && [ -f "$GEO_CACHE" ] && geo="$(cat "$GEO_CACHE")"

if [ -z "$geo" ]; then
  # No location at all: keep the previous reading if we have one.
  if [ -f "$LAST_GOOD" ]; then
    read -r icon label < "$LAST_GOOD"
    sketchybar --set "$NAME" icon="$icon" label="$label"
  else
    sketchybar --set "$NAME" icon="$WEATHER_NA" label="--"
  fi
  exit 0
fi

LAT="$(echo "$geo" | awk '{print $1}')"
LON="$(echo "$geo" | awk '{print $2}')"
CITY="$(echo "$geo" | awk '{print $3}')"

# --- weather --------------------------------------------------------------
# Retries cover the network still coming up right after wake / a Wi-Fi change.
read -r TEMP CODE IS_DAY <<<"$(curl -s --max-time 8 --retry 2 --retry-delay 3 --retry-all-errors \
  "https://api.open-meteo.com/v1/forecast?latitude=${LAT}&longitude=${LON}&current=temperature_2m,weather_code,is_day" \
  | python3 -c '
import sys, json
try:
    c = json.load(sys.stdin)["current"]
except Exception:
    raise SystemExit(1)
print(round(c["temperature_2m"]), c["weather_code"], c["is_day"])
' 2>/dev/null)"

if [ -z "$TEMP" ]; then
  if [ -f "$LAST_GOOD" ]; then
    read -r icon label < "$LAST_GOOD"
    sketchybar --set "$NAME" icon="$icon" label="$label"
  else
    sketchybar --set "$NAME" icon="$WEATHER_NA" label="--"
  fi
  # The last reading may be for the previous location, so retry soon instead of
  # leaving it up for the full 15 minutes.
  sketchybar --set "$NAME" update_freq=60
  exit 0
fi

# --- WMO code -> icon -----------------------------------------------------
# https://open-meteo.com/en/docs  (weather_code table)
day=$([ "$IS_DAY" = "1" ] && echo yes || echo no)

case "$CODE" in
  0|1)      [ "$day" = yes ] && ICON=$WEATHER_CLEAR_DAY  || ICON=$WEATHER_CLEAR_NIGHT ;;
  2)        [ "$day" = yes ] && ICON=$WEATHER_PARTLY_DAY || ICON=$WEATHER_PARTLY_NIGHT ;;
  3)        ICON=$WEATHER_CLOUDY ;;
  45|48)    ICON=$WEATHER_FOG ;;
  51|53|55|56|57) ICON=$WEATHER_DRIZZLE ;;
  61|63|65|66|67) ICON=$WEATHER_RAIN ;;
  71|73|75|77|85|86) ICON=$WEATHER_SNOW ;;
  80|81|82) ICON=$WEATHER_SHOWERS ;;
  95|96|99) ICON=$WEATHER_THUNDER ;;
  *)        ICON=$WEATHER_NA ;;
esac

# Prefix the city code when we have one: "VSG 16°", else just "16°".
if [ -n "$CITY" ]; then
  LABEL="${CITY} ${TEMP}°"
else
  LABEL="${TEMP}°"
fi
printf '%s %s' "$ICON" "$LABEL" > "$LAST_GOOD"
sketchybar --set "$NAME" icon="$ICON" label="$LABEL" update_freq=900
