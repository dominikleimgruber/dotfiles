#!/usr/bin/env sh

# Font names. sketchybarrc exports these, but plugin scripts are spawned by
# sketchybar itself and do not inherit them, so default them here too.
: "${FONT:=SF Pro}"
: "${NERD_FONT:=Hack Nerd Font}"

# SF Symbols glyphs (private-use codepoints, rendered by "SF Pro").

APPLE_ICN=􀣺

SUN_ICN=􀆮
MOON_ICN=􀆺

WIFI_ICN=􀙇
WIFI_OFF_ICN=􀙈
ETHERNET_ICN=󰈀   # nf-md-ethernet (U+F0200) - Nerd Font, NOT SF Symbols:
                          # the SF Symbols codepoint used here before did not exist
                          # in any installed font and rendered as a tofu box.
NETWORK_ICN=􀤆
SPEED_ICN=􀍾
IP_ICN=􀍥

CPU_ICN=􀧓

BATTERY_100=􀛨
BATTERY_75=􀺸
BATTERY_50=􀺶
BATTERY_25=􀛩
BATTERY_0=􀛪
BATTERY_CHARGING=􀢋

# Weather: Nerd Font glyphs (nf-weather-*), so these must be drawn with
# $NERD_FONT rather than SF Pro. Codepoints verified against the installed
# HackNerdFont-Regular.ttf cmap by glyph name.

WEATHER_CLEAR_DAY=   # nf-weather-day_sunny (U+E30D)
WEATHER_CLEAR_NIGHT=   # nf-weather-night_clear (U+E32B)
WEATHER_PARTLY_DAY=   # nf-weather-day_cloudy (U+E302)
WEATHER_PARTLY_NIGHT=   # nf-weather-night_alt_cloudy (U+E37E)
WEATHER_CLOUDY=   # nf-weather-cloudy (U+E312)
WEATHER_FOG=   # nf-weather-fog (U+E313)
WEATHER_DRIZZLE=   # nf-weather-sprinkle (U+E31B)
WEATHER_RAIN=   # nf-weather-rain (U+E318)
WEATHER_SHOWERS=   # nf-weather-showers (U+E319)
WEATHER_SNOW=   # nf-weather-snow (U+E31A)
WEATHER_THUNDER=   # nf-weather-thunderstorm (U+E31D)
WEATHER_NA=   # nf-weather-na (U+E374)

# Audio: Nerd Font glyphs (nf-md-*), drawn with $NERD_FONT like the weather
# icons. Codepoints verified against HackNerdFont-Regular.ttf by glyph name.

AUDIO_AIRPODS=󱡏   # nf-md-earbuds (U+F184F)
AUDIO_HEADPHONES=󰋋   # nf-md-headphones (U+F02CB)
AUDIO_DISPLAY=󰽟   # nf-md-monitor_speaker (U+F0F5F)
VOLUME_HIGH=󰕾   # nf-md-volume_high (U+F057E)
VOLUME_MEDIUM=󰖀   # nf-md-volume_medium (U+F0580)
VOLUME_LOW=󰕿   # nf-md-volume_low (U+F057F)
VOLUME_MUTED=󰖁   # nf-md-volume_off (U+F0581)
