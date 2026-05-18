# Screenshot Rofi Action Menu

## Problem

Current screenshot keybindings use `grimblast copy` which only copies to clipboard. `grimblast` may not be installed (not in `install.sh`). No file-saving workflow exists.

## Goal

Replace `grimblast copy` with a custom script that:
1. Uses `grimblast save` to capture to a temp file
2. Shows a Rofi action menu after **area** captures
3. Copies directly to clipboard for **output** and **screen** captures

## Design

### Script: `~/.config/hypr/scripts/screenshot.sh`

Single bash script, one argument: `area`, `output`, or `screen`.

**Non-area modes** (output, screen):
- `grimblast save <mode> /tmp/screenshot_XXXXX.png`
- `wl-copy < /tmp/screenshot_XXXXX.png`
- `notify-send` "Screenshot copied to clipboard"
- Clean up temp file

**Area mode:**
- `grimblast save area /tmp/screenshot_XXXXX.png`
- If capture failed (cancelled), clean up and exit silently
- Show Rofi menu via `rofi -dmenu` with three options:

| Option | Action |
|--------|--------|
| 💾 Save to screenshots | Copy to `$XDG_SCREENSHOTS_DIR/screenshot_YYYYMMDD_HHMMSS.png`, notify location |
| 📁 Choose location | Save to screenshots dir + `thunar` at that directory (or `xdg-open`) |
| 📋 Copy to clipboard | `wl-copy < tempfile`, notify |

### Default save directory

`$XDG_SCREENSHOTS_DIR` with fallback to `~/Pictures/Screenshots`.

### Keybinding changes (`hyprland.conf`)

Replace:
```
bind = , Print, exec, grimblast copy area
bind = SHIFT, Print, exec, grimblast copy output
bind = CTRL, Print, exec, grimblast copy screen
bind = $mainMod SHIFT, S, exec, grimblast copy area
```

With:
```
bind = , Print, exec, ~/.config/hypr/scripts/screenshot.sh area
bind = SHIFT, Print, exec, ~/.config/hypr/scripts/screenshot.sh output
bind = CTRL, Print, exec, ~/.config/hypr/scripts/screenshot.sh screen
bind = $mainMod SHIFT, S, exec, ~/.config/hypr/scripts/screenshot.sh area
```

### Dependencies

Add `grimblast-git` (AUR) to `install.sh`. `grim`, `slurp`, `wl-clipboard` already present.

### Rofi theme

Reuses existing `~/.config/rofi/config.rasi`. The menu uses `rofi -dmenu` with the default config.

### Notifications

Uses `notify-send` (available via SwayNC, already installed).

## Scope

- No new Rofi theme
- No clipboard history integration (already handled separately via cliphist)
- No OCR/text extraction (can be added later)
- File manager for "choose location" is `thunar` if available, fallback to `xdg-open`
