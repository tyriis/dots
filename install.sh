#!/bin/bash
set -e

# Dotfiles Installer
# Requires: Arch Linux, pacman

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo "Please do not run as root"
    exit 1
fi

# Check for pacman
if ! command -v pacman &> /dev/null; then
    echo "This script requires Arch Linux with pacman"
    exit 1
fi

# Install gum if not present
if ! command -v gum &> /dev/null; then
    echo "Installing gum..."
    sudo pacman -S --noconfirm gum
fi

gum style \
    --foreground 212 --border-foreground 212 --border double \
    --align center --width 50 --margin "1 2" --padding "1 2" \
    "Dotfiles Installer" "Arch Linux + Hyprland"

# System update
gum spin --spinner dot --title "Updating system..." -- sudo pacman -Syu --noconfirm

# AUR helper (yay)
if ! command -v yay &> /dev/null; then
    gum confirm "Install yay (AUR helper)?" && {
        gum spin --spinner dot --title "Installing yay..." -- \
            sh -c "sudo pacman -S --noconfirm --needed base-devel git && \
                   git clone https://aur.archlinux.org/yay.git /tmp/yay && \
                   cd /tmp/yay && makepkg -si --noconfirm && \
                   rm -rf /tmp/yay"
    }
fi

# PACMAN PACKAGES
pacman_packages=(
    hyprland waybar kitty rofi-wayland swaync
    hyprlock hypridle hyprsunset wlogout hyprpaper
    btop htop cliphist wl-clipboard grim slurp
    pavucontrol blueman brightnessctl
    gtk3 gtk4 qt6ct xsettingsd
    mise zsh zsh-autosuggestions zsh-syntax-highlighting
    ttf-firacode-nerd ttf-jetbrains-mono-nerd ttf-fira-sans
    noto-fonts-emoji
    pipewire pipewire-pulse wireplumber
    polkit-gnome networkmanager nm-connection-editor network-manager-applet
    eza bat ripgrep
)

gum spin --spinner dot --title "Installing pacman packages..." -- \
    sudo pacman -S --noconfirm --needed "${pacman_packages[@]}"

# AUR PACKAGES
if command -v yay &> /dev/null; then
    aur_packages=(
        google-chrome-stable
        brave-bin
        bibata-cursor-theme
        kora-icon-theme
        grimblast-git
    )

    gum spin --spinner dot --title "Installing AUR packages..." -- \
        yay -S --noconfirm --needed "${aur_packages[@]}"
fi

# MISE: install starship and fzf
if command -v mise &> /dev/null; then
    gum spin --spinner dot --title "Installing starship via mise..." -- \
        mise use -g starship@latest
    gum spin --spinner dot --title "Installing fzf via mise..." -- \
        mise use -g fzf@latest
fi

gum style \
    --foreground 76 --border-foreground 76 --border double \
    --align center --width 50 --margin "1 2" --padding "1 2" \
    "Installation Complete!" \
    "Run setup.sh to initialize dotfiles"
