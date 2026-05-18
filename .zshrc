# Zsh Configuration

# mise (tool version manager)
if command -v mise &> /dev/null; then
    eval "$(mise activate zsh)"
fi

# starship prompt
if command -v starship &> /dev/null; then
    eval "$(starship init zsh)"
fi

# fzf
if command -v fzf &> /dev/null; then
    eval "$(fzf --zsh)"
fi

# zsh-autosuggestions
if [ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# zsh-syntax-highlighting (must be last)
if [ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# Aliases
alias ll='eza -la --icons'
alias l='eza -l --icons'
alias la='eza -a --icons'
alias lt='eza -la --icons --tree --level=2'
alias cat='bat --paging=never'
alias grep='rg'
alias vim='nvim'
alias vi='nvim'
alias dots='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
alias update='sudo pacman -Syu'

# Environment
export EDITOR=nvim
export BROWSER=google-chrome-stable
export TERMINAL=kitty
export MOZ_ENABLE_WAYLAND=1
export XDG_SCREENSHOTS_DIR="$HOME/Pictures/Screenshots"

# History
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS

# Keybindings
bindkey -e
