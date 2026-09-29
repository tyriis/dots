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
    sudo pacman -S --noconfirm --needed nvidia-open nvidia-utils efibootmgr

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

# CUDA PATH
if pacman -Q cuda &>/dev/null; then
    echo ""
    echo ":: Setting up CUDA environment..."
    sudo tee /etc/profile.d/cuda.sh > /dev/null <<'EOF'
export PATH=/opt/cuda/bin:$PATH
export LD_LIBRARY_PATH=/opt/cuda/lib64:$LD_LIBRARY_PATH
EOF
    sudo chmod +x /etc/profile.d/cuda.sh
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
    sddm qt6-5compat qt6-svg qt6-multimedia qt6-multimedia-ffmpeg
    gst-plugins-base gst-plugins-good gst-plugins-bad gst-plugins-ugly xorg-xrandr
    btop htop cliphist cuda wl-clipboard grim slurp
    pavucontrol blueman brightnessctl
    gtk3 gtk4 qt6ct xdg-user-dirs xsettingsd
    mise zsh zsh-autosuggestions zsh-syntax-highlighting
    ttf-firacode-nerd ttf-jetbrains-mono-nerd ttf-fira-sans
    noto-fonts-cjk
    noto-fonts-emoji
    pipewire pipewire-pulse wireplumber
    polkit-gnome networkmanager nm-connection-editor network-manager-applet
    eza bat ripgrep libfido2
    7zip btrfs-progs cmake hashcat less mosquitto obsidian prismlauncher tig unzip vim wev wget zed
    neovim code docker docker-compose starship nvidia-container-toolkit openssh intel-ucode ipmitool ethtool tcpdump bind
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
        mqtt-explorer-appimage
        spotify
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

# SYSTEMD LOGIND: Ignore Power Key
echo ""
echo ":: Configuring systemd-logind to let Hyprland handle the power key..."
sudo sed -i 's/^#*HandlePowerKey=.*/HandlePowerKey=ignore/' /etc/systemd/logind.conf

# SSH AGENT: Enable user service for key caching
echo ""
echo ":: Enabling ssh-agent systemd user service..."
systemctl --user enable --now ssh-agent.service 2>/dev/null || echo "!! Could not enable. Run: systemctl --user enable --now ssh-agent.service"

# WAKE-ON-LAN: only a magic packet should wake this machine
# BIOS (manual, survives reinstall): APM -> "Power On By PCI-E: Enabled", "ErP Ready: Disabled"
echo ""
echo ":: Setting up Wake-on-LAN..."

# System unit: disable XHC/AWAC ACPI wake devices at boot
sudo cp "$HOME/system/disable-usb-acpi-wake.service" /etc/systemd/system/disable-usb-acpi-wake.service
sudo systemctl daemon-reload
sudo systemctl enable --now disable-usb-acpi-wake.service

# Persist WoL on the NIC (otherwise luck-dependent per boot)
CONN=$(nmcli -t -f NAME,TYPE connection show --active 2>/dev/null | awk -F: '$2=="802-3-ethernet"{print $1; exit}')
if [ -n "$CONN" ]; then
    echo ":: Enable WoL on connection '$CONN'? [Y/n]"
    read -r wol_answer || wol_answer="y"
    if [[ "$wol_answer" =~ ^[Yy]$ ]] || [ -z "$wol_answer" ]; then
        sudo nmcli connection modify "$CONN" 802-3-ethernet.wake-on-lan magic
        echo ":: WoL enabled on '$CONN'. Verify with: ethtool <iface> | grep Wake-on"
    fi
else
    echo "!! No active NetworkManager connection found. Run manually:"
    echo "   sudo nmcli connection modify \"<name>\" 802-3-ethernet.wake-on-lan magic"
fi

# TLP disables WoL by default — would silently break WoL
if pacman -Q tlp &>/dev/null && [ -f /etc/tlp.conf ]; then
    echo ":: TLP detected: setting WOL_DISABLE=N..."
    sudo sed -i 's/^#\?WOL_DISABLE=.*/WOL_DISABLE=N/' /etc/tlp.conf
fi

echo ""
echo "=== Installation Complete! ==="
echo "Run ./setup.sh to initialize dotfiles"
echo "After reboot, run: git config --global gpg.format ssh"
echo "  && git config --global user.signingkey ~/.ssh/id_ed25519_sk.pub"
echo "  && git config --global commit.gpgsign true"
