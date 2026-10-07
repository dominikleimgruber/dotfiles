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

**Permissions:** enable *Location Services* for `CoreLocationCLI` (weather) and
`sketchybar` (Wi-Fi name). The light/dark toggle asks for Automation permission on
first click.

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
