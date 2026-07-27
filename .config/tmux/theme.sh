# Catppuccin Mocha
set -g @catppuccin_flavor 'mocha'

# Status bar
set -g status-style "bg=#1e1e2e,fg=#cdd6f4"
set -g status-left-length 25
set -g status-right-length 50
set -g status-left "#[fg=#cba6f7,bold] #H #[fg=#45475a]│ #[fg=#a6e3a1]#S "
set -g status-right "#[fg=#89b4fa]%H:%M #[fg=#45475a]│ #[fg=#f9e2af]%d %b"

# Window status
setw -g window-status-format "#[fg=#6c7086] #I:#W "
setw -g window-status-current-format "#[fg=#1e1e2e,bg=#cba6f7,bold] #I:#W #[fg=#cba6f7,nobold]"

# Pane border
set -g pane-border-style "fg=#313244"
set -g pane-active-border-style "fg=#cba6f7"

# Message text
set -g message-style "bg=#313244,fg=#cdd6f4"

# Pane number display
set -g display-panes-active-colour "#cba6f7"
set -g display-panes-colour "#6c7086"

# Clock
setw -g clock-mode-colour "#cba6f7"

# Mode
setw -g mode-style "bg=#45475a,fg=#cdd6f4"

# Bell
setw -g window-status-bell-style "bg=#f38ba8,fg=#1e1e2e,bold"

# Activity
setw -g window-status-activity-style "bg=#1e1e2e,fg=#fab387,bold"

# Visual notification
setw -g monitor-activity on
set -g visual-activity off

# Center window list
set -g status-justify centre
