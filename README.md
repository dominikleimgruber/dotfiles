# dotfiles

macOS configuration for a keyboard-driven, tiling-window setup: AeroSpace manages
windows, sketchybar draws the status bar, Ghostty is the terminal, Neovim the editor.

Built and tested on macOS (Darwin 27) on Apple Silicon.

## What's in here

| Directory | Installs to | What it is |
| --- | --- | --- |
| `aerospace/` | `~/.config/aerospace/` | [AeroSpace](https://github.com/nikitabobko/AeroSpace) tiling window manager — workspaces, monitor assignment, gaps, keybindings |
| `sketchybar/` | `~/.config/sketchybar/` | [sketchybar](https://github.com/FelixKratz/SketchyBar) status bar — items, plugins, colors, icons |
| `nvim/` | `~/.config/nvim/` | Neovim, built on [LazyVim](https://www.lazyvim.org/) (see `nvim/README.md`) |
| `starship/starship.toml` | `~/.config/starship.toml` | [Starship](https://starship.rs) shell prompt |
| `wezterm/.wezterm.lua` | `~/.wezterm.lua` | WezTerm config, kept from before the switch to Ghostty |

These are symlinked into place — see [Installing](#installing).

## AeroSpace

**Eight workspaces split across monitors.** Each workspace lists monitor patterns in
priority order; the first pattern matching a *connected* monitor wins, and patterns
matching nothing are skipped. That makes one config cover every docking state:

| Displays connected | Workspaces 1–4 | Workspaces 5–8 |
| --- | --- | --- |
| Laptop + both 4Ks | DELL U2723QE | M27UP |
| Laptop + DELL only | DELL U2723QE | MacBook screen |
| Laptop + M27UP only | MacBook screen | M27UP |
| Laptop only | MacBook screen | MacBook screen |
| Office (two HP E27u G4) | HP E27u G4 (2) — main | HP E27u G4 (1) |

Monitor names are matched by regex, so **swapping displays means editing those
patterns** in `[workspace-to-monitor-force-assignment]`.

**Per-monitor padding.** Gaps are defined as `[{ monitor pattern = value }, default]`,
where the default applies to the external 4K panels and the `^Built-in.*$` branch to
the MacBook's own screen:

| | Built-in | 4K externals |
| --- | --- | --- |
| inner h/v | 8 | 12 |
| outer top | 15 | 55 |
| outer left/right/bottom | 8 | 12 |

The larger top gap leaves room for sketchybar (height 45, `y_offset` -5).

**Keybindings** (`alt` is the modifier throughout):

| Keys | Action |
| --- | --- |
| `alt-1` … `alt-8` | Focus workspace |
| `alt-shift-1` … `alt-shift-8` | Move window to workspace |
| `alt-h/j/k/l` | Focus left/down/up/right |
| `alt-shift-h/j/k/l` | Move window |
| `alt-shift--` / `alt-shift-=` | Resize |
| `alt-slash` / `alt-comma` | Tiles / accordion layout |
| `alt-ctrl-shift-f` | Fullscreen |
| `alt-ctrl-f` | Toggle floating/tiling |
| `alt-tab` | Back and forth |
| `alt-shift-tab` | Move workspace to next monitor |
| `alt-shift-;` | `service` mode (`esc` reload, `r` flatten, `f` float/tile, `backspace` close others) |
| `alt-shift-enter` | `apps` mode (`alt-w` Ghostty) |
| `alt-w` `alt-b` `alt-s` `alt-o` `alt-z` `alt-q` `alt-f` `alt-e` | Launch Ghostty, Brave, Safari, Obsidian, Zen, QuickTime, Finder, Final Cut |

> `alt-comma` switches a workspace to **accordion**, which deliberately overlaps
> windows. If tiling ever looks broken, that's the usual cause — `alt-slash` puts it
> back.

**Floating apps.** `on-window-detected` rules force `layout floating` for a short list
of utility windows (camera, Elgato, Cisco, QuickTime). Everything else tiles. Add an
app to that list only if it genuinely misbehaves when tiled.

## sketchybar

Visual style follows [shahmilav/carbonfiber-dots](https://github.com/shahmilav/carbonfiber-dots),
ported from yabai to AeroSpace: a 30px blurred bar, Catppuccin Macchiato palette, SF
Symbols icons.

```
sketchybarrc          bar geometry, defaults, and item load order
colors.sh             palette + BAR_COLOR / HIGHLIGHT / DIM
icons.sh              SF Symbols glyphs, plus Nerd Font weather glyphs
items/                one file per bar item: what it looks like
plugins/              one file per item: what it does when it updates
helper/               unused legacy C event provider (see Notes)
```

Items, left to right:

| Item | Notes |
| --- | --- |
| `apple.logo` | Static |
| `space.1` … `space.8` | AeroSpace workspaces; click to focus |
| `front_app` | Focused application |
| `appearance` | Light/dark toggle |
| `wifi.control` | Network icon; click for a popup with network name + IP |
| `cpu.*` | Stacked sys/user graph, busiest process, percentage |
| `battery` | Hides itself when no battery is present |
| `weather` | Outdoor temperature + city code; click to force a refresh |
| `clock` | Far right |

**Workspace pills.** AeroSpace has no macOS "spaces", so these are plain items, not
`space` items. A single hidden driver (`spaces.driver`) subscribes to the
`aerospace_workspace_change` event that `aerospace.toml` fires via
`exec-on-workspace-change`, and repaints all eight in one `sketchybar` call rather than
spawning eight scripts. Three tiers: focused gets a pill and bright text, a workspace
holding windows gets bright text, an empty one gets dimmed text.

**Weather** (`plugins/weather.sh`) resolves location at runtime so it follows you:

1. **CoreLocation** via `CoreLocationCLI --json` — the real device location.
   `--json` is deliberate: the `-format` path prints as soon as it has a coordinate
   fix, before reverse geocoding resolves, so `%locality` comes back empty.
2. **Public-IP geolocation** (`ip-api.com`) as fallback — only accurate to your ISP's
   egress point, which can be tens of kilometres off.

Readings come from [Open-Meteo](https://open-meteo.com) (no API key). Its WMO weather
code plus `is_day` drives the icon, so clear-day and clear-night differ. Location is
cached 30 min, weather refreshes every 15 min; clicking the item clears the location
cache and takes a fresh fix. If the network is down it keeps the last good reading
rather than blanking, and retries every minute until a fetch succeeds (so a reading
from the previous location doesn't linger after a Wi-Fi change).

`plugins/city_code.py` turns a city name into the short label — initials for multi-part
names (`New York` → `NY`, capped at 4), first three letters otherwise
(`Berlin` → `BER`), accents stripped. It also re-validates the coordinates, so an error
message can never be cached as a location.

Weather icons are Nerd Font `nf-weather-*` glyphs, not SF Symbols: SF Pro's symbol
glyphs are named opaquely (`uni100000.medium`), so there's no way to confirm which
private-use codepoint is which symbol. The Nerd Font ones were resolved against the
installed font's cmap *by glyph name*. The weather item therefore overrides the bar's
default icon font.

## Dependencies

```sh
brew tap nikitabobko/tap
brew tap felixkratz/formulae
brew trust --formula felixkratz/formulae/sketchybar felixkratz/formulae/borders

# window manager + bar
brew install --cask aerospace
brew install sketchybar borders

# fonts (SF Pro carries the SF Symbols glyphs; Hack Nerd Font the weather glyphs)
brew install --cask font-sf-pro font-sf-mono font-hack-nerd-font

# terminal, prompt, editor
brew install --cask ghostty
brew install starship neovim ripgrep fd   # rg/fd are used by LazyVim pickers

# real device location for the weather item
brew install --cask corelocationcli
```

`python3` is required by the weather plugin (system Python 3 is fine). `jq` is **not**
needed — only the removed yabai plugins used it.

### Permissions

Two items need macOS permissions that can't be granted from a script:

- **Weather** and the **Wi-Fi network name** both need *System Settings → Privacy &
  Security → Location Services*. Enable it for `CoreLocationCLI` (weather) and for
  `sketchybar` (network name). Without the latter, macOS redacts the SSID from every
  available source and the popup shows only the IP.
- The **light/dark toggle** uses `osascript` against System Events, so it prompts for
  Automation permission on first click.

## Installing

Each config is symlinked from this repo, so edits in `~/.config` land directly in git.
Back up any existing configs first:

```sh
cd ~/dotfiles
for t in aerospace sketchybar nvim; do ln -sfn "$PWD/$t" ~/.config/$t; done
ln -sfn "$PWD/starship/starship.toml" ~/.config/starship.toml
ln -sfn "$PWD/wezterm/.wezterm.lua"   ~/.wezterm.lua

chmod +x sketchybar/sketchybarrc sketchybar/plugins/*.sh sketchybar/plugins/*.py
```

Then reload:

```sh
aerospace reload-config
sketchybar --reload
```

sketchybar is started by AeroSpace's `after-startup-command`, not as a brew service,
so `brew services restart sketchybar` will not bring it back. Run `sketchybar &` or
restart AeroSpace.


## Notes

- `sketchybar/helper/` is a compiled C event provider from an earlier yabai-based
  config. Nothing in the current setup references it, and the compiled `helper` binary
  is tracked in git — worth removing or gitignoring on the next cleanup.
- Items removed in the carbonfiber rewrite (volume, Spotify, GitHub, brew, calendar,
  svim, yabai) remain in git history if you want to restyle any of them.
