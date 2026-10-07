#!/usr/bin/env bash
# Installs the tools these dotfiles need and symlinks the configs into place.
# Safe to re-run: existing symlinks are refreshed, real files/dirs are backed up.
#
# Usage: ./install.sh [--no-packages]   (--no-packages only creates the symlinks)

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d%H%M%S)"

FORMULAE=(sketchybar borders starship neovim ripgrep fd)
CASKS=(aerospace ghostty corelocationcli font-hack-nerd-font font-sf-pro font-sf-mono)

# source (relative to repo) -> target
LINKS=(
  "aerospace:$HOME/.config/aerospace"
  "sketchybar:$HOME/.config/sketchybar"
  "ghostty:$HOME/.config/ghostty"
  "nvim:$HOME/.config/nvim"
  "starship/starship.toml:$HOME/.config/starship.toml"
  "wezterm/.wezterm.lua:$HOME/.wezterm.lua"
)

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33mwarning:\033[0m %s\n' "$*" >&2; }

install_packages() {
  if ! command -v brew >/dev/null 2>&1; then
    info "Installing Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"
  fi

  info "Adding taps"
  brew tap nikitabobko/tap
  brew tap felixkratz/formulae
  # Newer Homebrew refuses formulae from third-party taps until they are trusted.
  if brew trust --help >/dev/null 2>&1; then
    brew trust --formula felixkratz/formulae/sketchybar felixkratz/formulae/borders
  fi

  info "Installing formulae"
  brew install "${FORMULAE[@]}"

  # One at a time so a single failure (e.g. a font pkg needing sudo) doesn't stop the rest.
  info "Installing casks"
  local failed=()
  for cask in "${CASKS[@]}"; do
    brew list --cask "$cask" >/dev/null 2>&1 && continue
    brew install --cask "$cask" || failed+=("$cask")
  done
  ((${#failed[@]})) && warn "could not install: ${failed[*]} (retry: brew install --cask ${failed[*]})"
  return 0
}

link_configs() {
  info "Linking configs"
  mkdir -p "$HOME/.config"
  local entry src dst
  for entry in "${LINKS[@]}"; do
    src="$DOTFILES/${entry%%:*}"
    dst="${entry#*:}"
    if [ -L "$dst" ]; then
      rm "$dst"
    elif [ -e "$dst" ]; then
      mkdir -p "$BACKUP"
      mv "$dst" "$BACKUP/"
      warn "backed up existing $dst to $BACKUP/"
    fi
    ln -s "$src" "$dst"
    echo "  $dst -> $src"
  done

  chmod +x "$DOTFILES"/sketchybar/sketchybarrc "$DOTFILES"/sketchybar/plugins/*.sh \
           "$DOTFILES"/sketchybar/plugins/*.py
}

setup_shell() {
  local zshrc="$HOME/.zshrc"
  if ! grep -qs 'starship init zsh' "$zshrc"; then
    info "Enabling starship in $zshrc"
    printf '\neval "$(starship init zsh)"\n' >> "$zshrc"
  fi
}

[ "${1:-}" = "--no-packages" ] || install_packages
link_configs
setup_shell

info "Done. Start AeroSpace (it launches sketchybar and borders), then grant Location"
info "Services to CoreLocationCLI and sketchybar in System Settings."
