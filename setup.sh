#!/bin/bash
set -e

# Dotfiles Setup Script
# Initializes bare git repo at $HOME/.dotfiles with $HOME as working tree

DOTFILES_REPO="$HOME/.dotfiles"

# Backup existing .dotfiles if present
if [ -d "$DOTFILES_REPO" ]; then
    echo "Existing .dotfiles found, backing up to .dotfiles.bak"
    mv "$DOTFILES_REPO" "${DOTFILES_REPO}.bak"
fi

# Determine the source: if running from the cloned repo, use local path
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
git clone --bare "file://$SCRIPT_DIR" "$DOTFILES_REPO"

# Configure the bare repo
git --git-dir="$DOTFILES_REPO" --work-tree="$HOME" config status.showUntrackedFiles no

# Checkout files
if git --git-dir="$DOTFILES_REPO" --work-tree="$HOME" checkout; then
    echo "Dotfiles checked out successfully"
else
    echo "Warning: Some files conflicted. Backing up conflicting files..."
    git --git-dir="$DOTFILES_REPO" --work-tree="$HOME" checkout 2>&1 | \
        grep "already exists" | awk '{print $3}' | while read -r file; do
        mkdir -p "$HOME/.dotfiles-backup/$(dirname "$file")"
        mv "$HOME/$file" "$HOME/.dotfiles-backup/$file"
    done
    git --git-dir="$DOTFILES_REPO" --work-tree="$HOME" checkout
fi

# Add alias to .zshrc if not present
ALIAS_LINE="alias dots='git --git-dir=\$HOME/.dotfiles --work-tree=\$HOME'"
if ! grep -q "alias dots=" "$HOME/.zshrc" 2>/dev/null; then
    echo "" >> "$HOME/.zshrc"
    echo "# Dotfiles alias" >> "$HOME/.zshrc"
    echo "$ALIAS_LINE" >> "$HOME/.zshrc"
    echo "Added 'dots' alias to .zshrc"
fi

echo ""
echo "Dotfiles setup complete!"
echo "Use 'dots' command to manage your dotfiles"
echo "Example: dots status"
echo "Example: dots add .config/waybar/style.css"
