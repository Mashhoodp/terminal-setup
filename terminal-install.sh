#!/bin/bash


# Check if necessary packages are installed, if not install them
for pkg in git zsh tmux curl xclip xsel alacritty bat; do
  command -v $pkg >/dev/null 2>&1 || {
    echo "⚙️ Installing $pkg..."
    sudo apt install -y $pkg
  }
done

# Change shell to zsh if not already
[ -z "$ZSH_VERSION" ] && sudo chsh -s $(which zsh) $USER

ZSH_PLUGIN_DIR="$HOME/.config/zsh"
TMUX_DIR="$HOME/.config/tmux"
STARSHIP_DIR="$HOME/.config"
ALACRITTY_DIR="$HOME/.config/alacritty"

# Create necessary directories
echo "📂 Creating config directories..."
mkdir -p $TMUX_DIR $ZSH_PLUGIN_DIR $ALACRITTY_DIR

# Copy configuration files
echo "📋 Copying dotfiles..."
cp dotfiles/tmux.conf $TMUX_DIR/
cp dotfiles/starship.toml $STARSHIP_DIR/
cp dotfiles/.zshrc $HOME/
cp dotfiles/alacritty.toml $ALACRITTY_DIR/
cp dotfiles/catppuccin-mocha.toml $ALACRITTY_DIR/
sudo cp -r JetBrainsMono /usr/share/fonts/truetype/

# Clone zsh plugins
echo "🔌 Cloning Zsh plugins..."
ZSH_PLUGINS=(
  "zsh-users/zsh-syntax-highlighting"
  "zsh-users/zsh-completions"
  "zsh-users/zsh-autosuggestions"
  "Aloxaf/fzf-tab"
)

for plugin in "${ZSH_PLUGINS[@]}"; do
  plugin_name=$(basename $plugin)
  if [ -d "$ZSH_PLUGIN_DIR/$plugin_name" ]; then
    echo "Updating $plugin_name..."
    git -C "$ZSH_PLUGIN_DIR/$plugin_name" pull
  else
    echo "Cloning $plugin_name..."
    git clone https://github.com/$plugin "$ZSH_PLUGIN_DIR/$plugin_name"
  fi
done

echo "🚀 Installing Starship..."
curl -sS https://starship.rs/install.sh | sh


echo "🚀 installing fzf..."
# Download and install the latest release of fzf
latest_release_info=$(curl -s https://api.github.com/repos/junegunn/fzf/releases/latest | sed 's/[^[:print:]\t]//g')
download_url=$(echo "$latest_release_info" | grep -o 'https://github.com/junegunn/fzf/releases/download/[^"]*linux_amd64.tar.gz')
curl -L -o fzf.tar.gz $download_url
tar -xzf fzf.tar.gz
rm fzf.tar.gz
chmod +x fzf
sudo mv fzf /usr/bin

echo "🚀 installing neovim"
# Download and install the latest release of neovim
latest_release_info=$(curl -s https://api.github.com/repos/neovim/neovim/releases/latest)
download_url=$(echo "$latest_release_info" | grep -o 'https://github.com/neovim/neovim/releases/download/[^"]*nvim-linux64.tar.gz' | head -n 1)
curl -L -o nvim-linux64.tar.gz $download_url
tar xzf nvim-linux64.tar.gz
sudo mv nvim-linux64 /opt/nvim
sudo ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim
rm nvim-linux64.tar.gz

echo "📂 Cloning NVChad config.."
# cloning NVchad configuration
mkdir -p $HOME/.config/nvim
sudo mkdir -p /root/.config
git clone https://github.com/NvChad/starter $HOME/.config/nvim
sudo cp $HOME/.config/nvim /root/.config/

# Define the plugin directory and tmux plugins
PLUGIN_DIR="$HOME/.tmux/plugins"
PLUGINS=(
  "tmux-plugins/tpm"
  "tmux-plugins/tmux-sensible"
  "christoomey/vim-tmux-navigator"
  "dreamsofcode-io/catppuccin-tmux"
  "tmux-plugins/tmux-yank"
)

# Create plugin directory if it doesn't exist and clone/update plugins
mkdir -p $PLUGIN_DIR
for plugin in "${PLUGINS[@]}"; do
  plugin_name=$(basename $plugin)
  if [ -d "$PLUGIN_DIR/$plugin_name" ]; then
    echo "🔄 Updating $plugin_name..."
    git -C "$PLUGIN_DIR/$plugin_name" pull
  else
    echo "📂 Cloning $plugin_name..."
    git clone https://github.com/$plugin "$PLUGIN_DIR/$plugin_name"
  fi
done

echo "🔄 Refreshing font cache...
fc-cache -fv

echo "🔗 Installing Tmux plugins..."
$HOME/.tmux/plugins/tpm/scripts/install_plugins.sh
echo "🎉 All set! Restart your terminal to apply changes."
