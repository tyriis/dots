#!/bin/bash
set -euo pipefail

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

echo "=== Dotfiles Installer ==="
echo "Arch Linux + Hyprland"
echo ""

# System update
echo ":: Updating system..."
sudo pacman -Syu --noconfirm

# NVIDIA driver (proprietary, replaces nouveau)
echo ""
echo ":: Install NVIDIA proprietary driver? [y/N]"
read -r nvidia_answer
if [[ "$nvidia_answer" =~ ^[Yy]$ ]]; then
    echo ":: Installing NVIDIA driver..."
    sudo pacman -S --noconfirm --needed nvidia-open-dkms nvidia-utils efibootmgr

    # Blacklist nouveau
    echo "blacklist nouveau" | sudo tee /etc/modprobe.d/blacklist-nouveau.conf > /dev/null

    # Add nvidia modules to initramfs
    if grep -q "^MODULES=(i915" /etc/mkinitcpio.conf; then
        sudo sed -i 's/^MODULES=(i915/MODULES=(i915 nvidia nvidia_modeset nvidia_uvm nvidia_drm/' /etc/mkinitcpio.conf
    else
        sudo sed -i 's/^MODULES=()/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf
    fi

    # Add nvidia_drm.modeset=1 to kernel cmdline (needed for Wayland)
    if command -v efibootmgr &> /dev/null; then
        BOOT_ENTRY=$(sudo efibootmgr -v 2>/dev/null | grep -E "^Boot[0-9a-fA-F]+\*" | grep -i "linux" | head -1)
        if [ -n "$BOOT_ENTRY" ]; then
            BOOTNUM=$(echo "$BOOT_ENTRY" | sed 's/^Boot\([0-9a-fA-F]*\)\*.*/\1/')
            if ! echo "$BOOT_ENTRY" | grep -q "nvidia_drm.modeset=1"; then
                sudo efibootmgr -b "$BOOTNUM" --append-args "nvidia_drm.modeset=1" 2>/dev/null || \
                    echo "!! Could not add kernel parameter. Run: sudo efibootmgr -b $BOOTNUM --append-args \"nvidia_drm.modeset=1\""
            fi
        else
            echo "!! Could not detect boot entry. Add 'nvidia_drm.modeset=1' to your kernel cmdline after reboot."
        fi
    fi

    # Rebuild initramfs
    echo ":: Rebuilding initramfs..."
    sudo mkinitcpio -P
    echo ":: NVIDIA driver installed. Reboot required."
fi

# AUR helper (yay)
if ! command -v yay &> /dev/null; then
    echo ""
    echo ":: yay not found. Install? [y/N]"
    read -r answer
    if [[ "$answer" =~ ^[Yy]$ ]]; then
        echo ":: Installing yay..."
        sudo pacman -S --noconfirm --needed base-devel git
        git clone https://aur.archlinux.org/yay.git /tmp/yay
        cd /tmp/yay && makepkg -si --noconfirm
        rm -rf /tmp/yay
    fi
fi

# PACMAN PACKAGES
pacman_packages=(
    hyprland waybar kitty rofi-wayland swaync uwsm
    hyprlock hypridle hyprsunset hyprpaper
    btop htop cliphist wl-clipboard grim slurp
    pavucontrol blueman brightnessctl
    gtk3 gtk4 qt6ct xsettingsd
    mise zsh zsh-autosuggestions zsh-syntax-highlighting
    ttf-firacode-nerd ttf-jetbrains-mono-nerd ttf-fira-sans
    noto-fonts-emoji
    pipewire pipewire-pulse wireplumber
    polkit-gnome networkmanager nm-connection-editor network-manager-applet
    eza bat ripgrep libfido2
    neovim code starship openssh intel-ucode
)

echo ""
echo ":: Installing pacman packages..."
sudo pacman -S --noconfirm --needed "${pacman_packages[@]}"

# AUR PACKAGES
if command -v yay &> /dev/null; then
    aur_packages=(
        bibata-cursor-theme
        brave-bin
        ccat
        google-chrome-stable
        grimblast-git
        kora-icon-theme
        vesktop
        wlogout
    )

    echo ""
    echo ":: Installing AUR packages..."
    yay -S --noconfirm --needed "${aur_packages[@]}"
fi

# MISE: install fzf
if command -v mise &> /dev/null; then
    echo ""
    echo ":: Installing fzf via mise..."
    mise use -g fzf@latest
fi

# SSH AGENT: Enable user service for key caching
echo ""
echo ":: Enabling ssh-agent systemd user service..."
systemctl --user enable --now ssh-agent.service 2>/dev/null || echo "!! Could not enable. Run: systemctl --user enable --now ssh-agent.service"

echo ""
echo "=== Installation Complete! ==="
echo "Run ./setup.sh to initialize dotfiles"
echo "After reboot, run: git config --global gpg.format ssh"
echo "  && git config --global user.signingkey ~/.ssh/id_ed25519_sk.pub"
echo "  && git config --global commit.gpgsign true"
