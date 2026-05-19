# Dotfiles

Arch Linux + Hyprland (Wayland) dotfiles, Catppuccin Macchiato.

## Project structure

```
.config/
  hypr/          # hyprland, hyprlock, hypridle, hyprpaper, hyprsunset
  waybar/        # bottom bar config + Catppuccin theme (colors.css)
  kitty/         # terminal emulator
  rofi/          # app launcher
  swaync/        # notification daemon
  wlogout/       # power menu
  btop/          # system monitor
  gtk-3.0/       # GTK theme overrides
  gtk-4.0/
  qt6ct/         # Qt theming
  xsettingsd/    # GTK settings daemon
  cliphist/      # clipboard manager
.zshrc           # Zsh with mise + starship + fzf
```

## Commands

```sh
./install.sh       # pacman packages + yay AUR + mise tools
./setup.sh         # init bare git repo at ~/.dotfiles with $HOME as worktree
```

After setup, use `dots` alias for git:
```sh
dots status
dots add .config/hypr/hyprland.conf
dots commit -m "message"
dots push
```

## Keybindings (hyprland.conf)

| Key | Action |
|-----|--------|
| Super+Return | kitty |
| Super+Q | kill active |
| Super+D | rofi drun |
| Super+Space | rofi run |
| Super+F | fullscreen |
| Super+L | hyprlock |
| Super+Escape | wlogout |
| Super+V | toggle floating |
| Super+Shift+S | grimblast copy area |
| Super+Shift+H | cliphist list → rofi → wl-copy |
| Print | grimblast copy area |
| Shift+Print | grimblast copy output |

## Style conventions

- Catppuccin Macchiato palette: bg `#24273a`, surface `#363a4f`, blue `#8aadf4`, text `#cad3f5`
- Hyprland borders: active `#8aadf4`, inactive `#363a4f`
- All configs follow this theme. Match palette in new additions.
- Waybar: bottom bar. Colors in `colors.css`, imported by `style.css`.
- Shell: Zsh, no oh-my-zsh — just autosuggestions + syntax-highlighting plugins.
