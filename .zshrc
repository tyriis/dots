# Zsh Configuration

# Start- und Ende-Tasten
bindkey -e
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line

# Entfernen-Taste
bindkey '^[[3~' delete-char

# Bild-auf und Bild-ab (Verlauf durchsuchen)
bindkey '^[[5~' up-line-or-history
bindkey '^[[6~' down-line-or-history


# mise (tool version manager)
if [[ "$(command -v mise)" ]]; then
  eval "$(command mise activate zsh)"
fi

# direnv (mise-managed)
if [[ "$(command -v direnv)" ]]; then
  eval "$(direnv hook zsh)"
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
alias grep='rg'
alias vim='nvim'
alias vi='nvim'
alias dots='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
alias cat='ccat'
alias update='sudo pacman -Syu'

# Environment
export EDITOR=nvim
export BROWSER=google-chrome-stable
export TERMINAL=kitty
export MOZ_ENABLE_WAYLAND=1
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"

# History
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS

# Keybindings
# bindkey -e

# Add SSH key if agent has no keys
ssh-add -l >/dev/null 2>&1
if [ $? -eq 1 ]; then
    ssh-add ~/.ssh/id_ed25519_sk_touch
fi

# git-commit-guardrail:lefthook-config
[ -z "$LEFTHOOK_CONFIG" ] && export LEFTHOOK_CONFIG="$HOME/.config/git-commit/lefthook.yml"

. "$HOME/.local/bin/env"

# pnpm
export PNPM_HOME="/home/nils/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac
# pnpm end

# Hermes Agent command
case ":$PATH:" in *":$HOME/.local/bin:"*) ;; *) export PATH="$HOME/.local/bin:$PATH" ;; esac

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
