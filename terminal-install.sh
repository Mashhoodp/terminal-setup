#!/bin/bash

# Exit on error
set -e

# --- Helper Functions ---
log() {
    echo -e "\033[1;34m[INFO]\033[0m $1"
}

warn() {
    echo -e "\033[1;33m[WARN]\033[0m $1"
}

error() {
    echo -e "\033[1;31m[ERROR]\033[0m $1"
}

# --- OS Detection ---
log "🕵️ Detecting Operating System..."
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    LIKE_OS=$ID_LIKE
else
    error "Cannot detect OS. Exiting."
    exit 1
fi

# Define Package Lists
# Common packages across distros
COMMON_PKGS="git zsh tmux curl unzip fontconfig neovim wl-clipboard xclip fzf lazygit"

# --- Installation Logic ---

if [[ "$OS" == "arch" || "$LIKE_OS" == *"arch"* ]]; then
    log "🚀 Arch Linux detected. Using pacman."
    
    # Arch packages
    ARCH_PKGS="$COMMON_PKGS alacritty ghostty bat lazygit starship eza"
    
    sudo pacman -Syu --noconfirm
    sudo pacman -S --needed --noconfirm $ARCH_PKGS

elif [[ "$OS" == "fedora" || "$LIKE_OS" == *"fedora"* ]]; then
    log "🎩 Fedora detected. Using dnf."

    # Fedora packages
    FEDORA_PKGS="$COMMON_PKGS bat eza"

    sudo dnf upgrade -y
    sudo dnf install -y $FEDORA_PKGS

    # Handle Ghostty and Starship (via COPR and atim)
    log "👻 Installing Ghostty via COPR..."
    # Ensure core plugins are installed for the 'copr' command
    sudo dnf install -y dnf-plugins-core
    sudo dnf copr enable scottames/ghostty -y
    sudo dnf install -y ghostty
    log "🚀 Installing Starship..."
    sudo dnf copr enable atim/starship -y
    sudo dnf install -y starship

    # Handle Lazyvim
    if [ ! -d ~/.config/nvim ]; then
        log "🛠️ Installing lazyvim..."
        git clone https://github.com/LazyVim/starter ~/.config/nvim
        rm -rf ~/.config/nvim/.git
    else
        log "🛠️ Lazyvim already installed, skipping..."
    fi

elif [[ "$OS" == "debian" || "$OS" == "kali" || "$LIKE_OS" == *"debian"* ]]; then
    log "🛡️ Debian/Kali detected. Using apt."
    
    # Debian specific handling
    # 'bat' is called 'batcat' in debian
    DEB_PKGS="$COMMON_PKGS alacritty"
    
    sudo apt update
    sudo apt install -y $DEB_PKGS

    # Handle Bat (Debian names it batcat)
    if ! command -v batcat &> /dev/null; then
        sudo apt install -y bat
    fi
    # Create alias for bat if it doesn't exist
    mkdir -p ~/.local/bin
    if command -v batcat &> /dev/null && ! command -v bat &> /dev/null; then
        ln -sf /usr/bin/batcat ~/.local/bin/bat
        export PATH=$HOME/.local/bin:$PATH
    fi

    # Handle Lazyvim
    if [ ! -d ~/.config/nvim ]; then
        log "🛠️ Installing lazyvim..."
        git clone https://github.com/LazyVim/starter ~/.config/nvim
        rm -rf ~/.config/nvim/.git
    else
        log "🛠️ Lazyvim already installed, skipping..."
    fi
    

    # Handle Starship (Debian repos might be old)
    if ! command -v starship &> /dev/null; then
        log "🚀 Installing Starship via script..."
        curl -sS https://starship.rs/install.sh | sh -s -- -y
    fi

    # Handle Ghostty (Try apt, warn if fail)
    if sudo apt install -y ghostty 2>/dev/null; then
        log "👻 Ghostty installed."
    else
        warn "Ghostty not found in apt repositories. You may need to build it manually or use a flatpak."
    fi

else
    error "Unsupported OS: $OS"
    exit 1
fi

# --- Configuration Setup ---

# Directories
ZSH_PLUGIN_DIR="$HOME/.config/zsh"
TMUX_DIR="$HOME/.config/tmux"
STARSHIP_DIR="$HOME/.config"
ALACRITTY_DIR="$HOME/.config/alacritty"
GHOSTTY_DIR="$HOME/.config/ghostty"

log "📂 Creating config directories..."
mkdir -p "$TMUX_DIR" "$ZSH_PLUGIN_DIR" "$ALACRITTY_DIR" "$GHOSTTY_DIR"

# Check if dotfiles folder exists
if [ -d "dotfiles" ]; then
    log "📋 Copying dotfiles..."
    [ -f dotfiles/tmux.conf ] && cp dotfiles/tmux.conf "$TMUX_DIR/"
    [ -f dotfiles/starship.toml ] && cp dotfiles/starship.toml "$STARSHIP_DIR/"
    [ -f dotfiles/.zshrc ] && cp dotfiles/.zshrc "$HOME/"
    [ -f dotfiles/alacritty.toml ] && cp dotfiles/alacritty.toml "$ALACRITTY_DIR/"
    [ -f dotfiles/config ] && cp dotfiles/config "$GHOSTTY_DIR/" 
    
    # Copy fonts if they exist
    if [ -d "JetBrainsMono" ]; then
        log "fonts Installing Fonts..."
        sudo cp -r JetBrainsMono /usr/share/fonts/truetype/
        fc-cache -fv
    fi
else
    warn "dotfiles/ directory not found in current path. Skipping config copy."
fi

# --- Zsh Setup ---

# Change shell to zsh if not already
if [ "$SHELL" != "$(which zsh)" ]; then
    log "🐚 Changing default shell to Zsh..."
    sudo chsh -s "$(which zsh)" "$USER"
fi

log "🔌 Setting up Zsh plugins..."
ZSH_PLUGINS=(
  "zsh-users/zsh-syntax-highlighting"
  "zsh-users/zsh-completions"
  "zsh-users/zsh-autosuggestions"
  "Aloxaf/fzf-tab"
)

for plugin in "${ZSH_PLUGINS[@]}"; do
  plugin_name=$(basename "$plugin")
  if [ -d "$ZSH_PLUGIN_DIR/$plugin_name" ]; then
    log "Updating $plugin_name..."
    git -C "$ZSH_PLUGIN_DIR/$plugin_name" pull
  else
    log "Cloning $plugin_name..."
    git clone "https://github.com/$plugin" "$ZSH_PLUGIN_DIR/$plugin_name"
  fi
done

# --- Tmux Setup ---

PLUGIN_DIR="$HOME/.tmux/plugins"
TMUX_PLUGINS=(
  "tmux-plugins/tpm"
  "tmux-plugins/tmux-sensible"
  "christoomey/vim-tmux-navigator"
  "dreamsofcode-io/catppuccin-tmux"
  "tmux-plugins/tmux-yank"
)

log "💻 Setting up Tmux plugins..."
mkdir -p "$PLUGIN_DIR"
for plugin in "${TMUX_PLUGINS[@]}"; do
  plugin_name=$(basename "$plugin")
  if [ -d "$PLUGIN_DIR/$plugin_name" ]; then
    log "Updating $plugin_name..."
    git -C "$PLUGIN_DIR/$plugin_name" pull
  else
    log "Cloning $plugin_name..."
    git clone "https://github.com/$plugin" "$PLUGIN_DIR/$plugin_name"
  fi
done

# Install TPM plugins
if [ -f "$PLUGIN_DIR/tpm/scripts/install_plugins.sh" ]; then
    log "Running TPM install script..."
    "$PLUGIN_DIR/tpm/scripts/install_plugins.sh"
fi

# --- Cleanup & Finish ---

log "🎉 All set! Please restart your terminal."
