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
app, light/dark toggle, Wi-Fi, CPU, battery, weather and clock. The weather item uses
your current location (CoreLocation, falling back to IP) and
[Open-Meteo](https://open-meteo.com); click it to refresh.

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

### sketchybar is not running

It is started by AeroSpace's `after-startup-command`, **not** as a brew service, so
`brew services restart sketchybar` will not bring it back. Restart AeroSpace, or run
`sketchybar &` directly.
