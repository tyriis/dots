# Dotfiles

Arch Linux + Hyprland (Wayland) dotfiles, Catppuccin Macchiato.

## CRITICAL: After every file edit

**Always** present a summary of changes and ask if I want to commit via `git --git-dir=$HOME/.dotfiles --work-tree=$HOME commit -m "..."`.
This applies to ANY file tracked by the dotfiles repo (`install.sh`, `.config/*`, `.zshrc`, etc.).
Never skip this step. Do not assume I will ask — proactively prompt after every edit.

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

Use the dotfiles git command for all git operations:
```sh
git --git-dir=$HOME/.dotfiles --work-tree=$HOME status
git --git-dir=$HOME/.dotfiles --work-tree=$HOME add .config/hypr/hyprland.conf
git --git-dir=$HOME/.dotfiles --work-tree=$HOME commit -m "message"
git --git-dir=$HOME/.dotfiles --work-tree=$HOME push
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

## Hard Rules

- **NEVER run sudo.** I will run sudo commands myself. Show me the command and I'll run it.
- After EVERY edit to a dotfiles-tracked file: present changes summary → ask `git --git-dir=$HOME/.dotfiles --work-tree=$HOME commit -m "..."`
- This is non-negotiable. Do it every time, without exception.

## Style conventions

- Catppuccin Macchiato palette: bg `#24273a`, surface `#363a4f`, blue `#8aadf4`, text `#cad3f5`
- Hyprland borders: active `#8aadf4`, inactive `#363a4f`
- All configs follow this theme. Match palette in new additions.
- Waybar: bottom bar. Colors in `colors.css`, imported by `style.css`.
- Shell: Zsh, no oh-my-zsh — just autosuggestions + syntax-highlighting plugins.
