#!/usr/bin/env bash

set -e

echo "==================================="
echo " Fedora Post Installation Script"
echo "==================================="

# Check for sudo
sudo -v

echo
echo "==> Updating Fedora..."
sudo dnf upgrade --refresh -y

echo
echo "==> Enabling RPM Fusion repositories..."
sudo dnf install -y \
  https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

echo
echo "==> Installing multimedia codecs..."
sudo dnf swap ffmpeg-free ffmpeg --allowerasing -y
sudo dnf group upgrade multimedia -y
sudo dnf group upgrade core -y

echo
echo "==> Enabling Terra repository..."
sudo dnf install --nogpgcheck -y \
  --repofrompath "terra,https://repos.fyralabs.com/terra\$releasever" \
  terra-release

echo
echo "==> Installing essential packages..."
sudo dnf install -y fuse-libs gnome-tweaks fastfetch openh264 gstreamer1-plugin-openh264 adw-gtk3-theme

echo "==> Installing Virtualization Support"
sudo dnf install @virtualization -y
sudo usermod -aG libvirt $USER

echo "==> Adding Brave Browser repository..."
sudo dnf config-manager addrepo --from-repofile=https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo

echo "==> Installing Brave Origin Browser..."
sudo dnf install brave-origin

echo
echo "==> Detecting GPU..."

if lspci | grep -i "NVIDIA"; then
  echo "NVIDIA GPU detected"
  sudo dnf install -y akmod-nvidia xorg-x11-drv-nvidia-cuda

elif lspci | grep -i "AMD"; then
  echo "AMD GPU detected"
  echo "AMD GPU uses the open-source Mesa drivers."
  echo "No additional proprietary drivers needed."

else
  echo "No NVIDIA or AMD GPU detected."
fi

echo
echo "==> Setting up Flatpak..."
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

echo
echo "==> Installing Flatpak applications..."

flatpak install -y flathub io.missioncenter.MissionCenter com.mattjakeman.ExtensionManager

echo
echo "==> Configuring GNOME..."

# Enable minimize and maximize buttons
gsettings set org.gnome.desktop.wm.preferences button-layout ':minimize,maximize,close'

# Disable hot corner
gsettings set org.gnome.desktop.interface enable-hot-corners false

echo
echo "======================================"
echo "          Setup Complete!"
echo "======================================"

echo
echo "Recommended GNOME Extensions:"
echo " - Dash to Dock"
echo " - Compiz alike Magic Lamp Effect"
echo " - Compiz alike Windows Effect"
echo " - AppIndicator and KStatusNotifierItem Support"
echo " - Blur my Shell"
echo " - Clipboard Indicator"
echo " - Caffeine"
echo " - Just Perfection"

echo
echo "Open Extension Manager to install them."

echo
echo "For NVIDIA users:"
echo " - Reboot after driver installation."
echo " - Wait a few minutes after installation so akmods can build the kernel module."

echo
echo "Enjoy your Fedora system!"
