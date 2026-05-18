# Dotfiles

Personal dotfiles for Arch Linux with Hyprland on Wayland.

## Included Configurations

- **WM:** Hyprland (Wayland) with uwsm session manager
- **Bar:** Waybar (bottom, Catppuccin Macchiato)
- **Terminal:** Kitty
- **Launcher:** Rofi
- **Notifications:** SwayNC
- **Power Menu:** Wlogout
- **Shell:** Zsh + mise/starship/fzf
- **Theme:** Catppuccin Macchiato throughout

## Installation

### 1. Install packages

```sh
./install.sh
```

### 2. Set up dotfiles (bare git repo)

```sh
./setup.sh
```

This creates a bare git repo at `~/.dotfiles` with `$HOME` as the working tree.
Use the `dots` command to manage files:

```sh
dots status
dots add .config/hypr/hyprland.conf
dots commit -m "update hyprland config"
dots push
```
