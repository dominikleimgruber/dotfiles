# dotfiles

macOS setup: [AeroSpace](https://github.com/nikitabobko/AeroSpace) (tiling window manager),
[sketchybar](https://github.com/FelixKratz/SketchyBar) (status bar),
[Ghostty](https://ghostty.org) (terminal), [Neovim](https://www.lazyvim.org/) (LazyVim)
and [Starship](https://starship.rs) (prompt).

| Directory | Symlinked to |
| --- | --- |
| `aerospace/` | `~/.config/aerospace` |
| `sketchybar/` | `~/.config/sketchybar` |
| `ghostty/` | `~/.config/ghostty` |
| `nvim/` | `~/.config/nvim` |
| `starship/starship.toml` | `~/.config/starship.toml` |
| `wezterm/.wezterm.lua` | `~/.wezterm.lua` (legacy) |

## Install

```sh
git clone git@github.com:dominikleimgruber/dotfiles.git ~/dotfiles
~/dotfiles/install.sh
```

The script installs Homebrew and all tools, symlinks the configs (existing ones are
moved to `~/.dotfiles-backup/`) and enables Starship in `~/.zshrc`. It is safe to
re-run; `--no-packages` only refreshes the symlinks. Afterwards, start AeroSpace; it
launches sketchybar and borders itself.

> **Clone it to `~/dotfiles`, not into `~/Documents`, `~/Desktop` or `~/Downloads`.**
> macOS guards those three folders: an app must hold an explicit "access files in your
> Documents folder" grant to read them. Your terminal usually has it, but AeroSpace.app
> does not — so with the configs symlinked into `~/Documents`, AeroSpace follows the
> link, is refused by the OS, and **silently falls back to its built-in defaults**
> instead of reporting an error. See [Troubleshooting](#troubleshooting).

**Permissions:** enable *Location Services* for `CoreLocationCLI` (weather) and
`sketchybar` (Wi-Fi name). The light/dark toggle asks for Automation permission on
first click. Without the `sketchybar` grant, macOS redacts the Wi-Fi SSID from every
available source and the network popup shows only the IP address.

## AeroSpace

Workspaces 1–4 go to the primary monitor and 5–8 to the secondary one; without
external displays all eight are on the built-in screen. To add a new monitor, put
its name (`aerospace list-monitors`) into `[workspace-to-monitor-force-assignment]`.

| Keys | Action |
| --- | --- |
| `alt-1…8` / `alt-shift-1…8` | Focus / move window to workspace |
| `alt-h/j/k/l` / `alt-shift-h/j/k/l` | Focus / move window |
| `alt-shift--` / `alt-shift-=` | Resize |
| `alt-slash` / `alt-comma` | Tiles / accordion layout |
| `alt-ctrl-f` / `alt-ctrl-shift-f` | Toggle floating / fullscreen |
| `alt-tab` / `alt-shift-tab` | Previous workspace / move workspace to next monitor |
| `alt-shift-;` | Service mode (`esc` reload, `r` reset layout) |
| `alt-w/b/s/o/z/q/f/e` | Ghostty, Firefox, Safari, Obsidian, Zen, QuickTime, Finder, Final Cut |

## sketchybar

Catppuccin Macchiato bar based on
[carbonfiber-dots](https://github.com/shahmilav/carbonfiber-dots): workspaces, front
app, light/dark toggle, network, CPU, battery, audio, weather and clock. The weather
item uses your current location (CoreLocation, falling back to IP) and
[Open-Meteo](https://open-meteo.com); click it to refresh.

**Audio.** The icon reflects what you are actually listening through:

| Output | Icon |
| --- | --- |
| AirPods (matched by name) | `nf-md-earbuds` |
| Other headphones / headsets | `nf-md-headphones` |
| Monitor over HDMI or DisplayPort | `nf-md-monitor_speaker` |
| Built-in, USB or virtual output | `nf-md-volume_{high,medium,low}`, following the level |
| Muted, or volume 0 | `nf-md-volume_off`, dimmed |

Device type comes from `coreaudio_device_transport` in `system_profiler
SPAudioDataType`, since `SwitchAudioSource` reports the name but not the connection.
AirPods and most headsets are matched on the device name, so they do not depend on the
transport at all; an unrecognised Bluetooth device is assumed to be headphones unless
its name looks like a speaker. The classification lives in
`plugins/audio_device.py`.

Because that lookup costs ~0.2s and `volume_change` fires rapidly while a volume key
is held, the category is cached: volume events only read the cache, and the category is
re-resolved on the 5s tick, on wake, and right after a device switch. So a newly
connected device can take up to 5s to change the icon.

Changing the volume briefly slides a level bar open next to the icon. Clicking the icon
opens a popup listing every output device, with the active one highlighted; clicking one
switches to it via `SwitchAudioSource`.

**Icon fonts.** Icons come from two sources: SF Symbols private-use codepoints rendered
by `SF Pro`, and Nerd Font glyphs (`nf-md-*`, `nf-weather-*`) rendered by
`Hack Nerd Font`. Any item mixing both — the network item switches between an SF Symbols
Wi-Fi glyph and a Nerd Font ethernet glyph — **must set `icon.font` on every branch**,
or the wrong font is left applied and the glyph renders as a tofu box. A codepoint that
exists in neither font always renders as a box; see
[Troubleshooting](#an-icon-shows-as-a-box-tofu).

Reload with `sketchybar --reload`.

## Troubleshooting

### AeroSpace ignores this config and uses its own defaults

**Symptoms.** `alt-w` switches to a workspace called `W` instead of opening Ghostty
(same for `alt-o`, `alt-b`, …), window gaps are gone, workspaces `A`–`Z` appear
alongside `1`–`8`, and the workspace-to-monitor split is not applied.

**Cause.** AeroSpace cannot read the config file, so it loads its built-in defaults.
Those defaults bind every `alt-<letter>` to "switch to workspace `<LETTER>`", which is
why launcher shortcuts turn into workspace jumps. The usual reason is the repo sitting
in a macOS-protected folder — see the warning under [Install](#install).

**Why it is easy to miss.** These all keep reporting success:

```sh
aerospace reload-config            # exits 0
aerospace reload-config --dry-run  # exits 0
aerospace config --config-path     # prints the correct path
```

They run as *your shell*, which can read the file, so it parses and validates fine.
The process that actually applies the config is AeroSpace.app, and it is the one being
refused. Nothing surfaces the denial.

**Diagnosis.** Ask the running instance what it actually has, rather than reading the
file:

```sh
aerospace config --major-keys                      # expect: mode.main.binding, mode.apps.binding, ...
aerospace config --get mode.main.binding.alt-w     # expect: exec-and-forget open -a ...Ghostty.app
aerospace list-workspaces --all                    # expect: 1..8, with no A-Z
```

If `--major-keys` is missing `mode.apps.binding`, or `alt-w` comes back as
`workspace W`, the running config is *not* this repo's.

**Fix.** Move the repo somewhere unprotected and relink:

```sh
mv ~/Documents/dotfiles ~/dotfiles
~/dotfiles/install.sh --no-packages
killall AeroSpace && open -a AeroSpace
```

Granting AeroSpace access to the protected folder also works, but has to be repeated on
every machine, and sketchybar — launched by AeroSpace via `after-startup-command` — can
inherit the same denial, so moving the repo is the more reliable fix.

### Windows overlap instead of tiling

Either the workspace is in **accordion** layout (`alt-comma`; `alt-slash` returns it to
tiles), or the app matches an `on-window-detected` rule that forces `layout floating`.
Check with:

```sh
aerospace list-windows --all --format '%{workspace} %{app-name} %{window-layout}'
```

### An icon shows as a box (tofu)

Either the codepoint exists in no installed font, or the item's `icon.font` is set to a
font that lacks it (see **Icon fonts** above). Audit every glyph in `icons.sh` against
both fonts:

```sh
python3 -m venv /tmp/ftenv && /tmp/ftenv/bin/pip install -q fonttools
/tmp/ftenv/bin/python - <<'EOF'
from fontTools.ttLib import TTFont
import os, re
sfpro = set(TTFont('/Library/Fonts/SF-Pro.ttf').getBestCmap())
hack  = set(TTFont(os.path.expanduser(
    '~/Library/Fonts/HackNerdFont-Regular.ttf')).getBestCmap())
for line in open(os.path.expanduser('~/dotfiles/sketchybar/icons.sh')):
    m = re.match(r'^([A-Z0-9_]+)=(\S)\s*$', line)
    if m and ord(m.group(2)) not in sfpro | hack:
        print('TOFU:', m.group(1), hex(ord(m.group(2))))
EOF
```

SF Pro's symbol glyphs are named opaquely (`uni100000.medium`), so a symbol **name**
cannot be resolved to a codepoint from the font — only presence can be checked. Nerd
Font glyphs keep meaningful names (`md-ethernet`, `weather-day_sunny`), so prefer those
for anything new and look the codepoint up by name rather than guessing it.

### sketchybar is not running

It is started by AeroSpace's `after-startup-command`, **not** as a brew service, so
`brew services restart sketchybar` will not bring it back. Restart AeroSpace, or run
`sketchybar &` directly.
