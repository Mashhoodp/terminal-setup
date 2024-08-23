#!/bin/bash


# Check if necessary packages are installed, if not install them
for pkg in git zsh tmux curl xclip xsel alacritty batcat; do
  command -v $pkg >/dev/null 2>&1 || {
    echo "Installing $pkg..."
    sudo apt install -y $pkg
  }
done

# Change shell to zsh if not already
[ -z "$ZSH_VERSION" ] && sudo chsh -s $(which zsh) $USER

ZSH_PLUGIN_DIR="$HOME/.config/zsh"
TMUX_DIR="$HOME/.config/tmux"
OHMYPOSH_DIR="$HOME/.config/ohmyposh"
ALACRITTY_DIR="$HOME/.config/alacritty

# Create necessary directories
mkdir -p $TMUX_DIR
mkdir -p $OHMYPOSH_DIR
mkdir -p $ZSH_PLUGIN_DIR
mkdir -p $ALACRITTY_DIR

# Copy configuration files
echo "Copying config files..."
cp dotfiles/tmux.conf $TMUX_DIR/
cp dotfiles/zen.toml $OHMYPOSH_DIR/
cp dotfiles/.zshrc $HOME/
cp dotfiles/alacritty.toml $ALACRITTY_DIR/
cp dotfiles/catppuccin-mocha.toml $ALACRITTY_DIR/

# Clone zsh plugins
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

echo "installing oh-my-posh"
# Download and install the latest release of oh-my-posh
latest_release_info=$(curl -s https://api.github.com/repos/JanDeDobbeleer/oh-my-posh/releases/latest | sed 's/[^[:print:]\t]//g')
download_url=$(echo "$latest_release_info" | grep -o 'https://github.com/[^"]*posh-linux-amd64')
curl -L -o oh-my-posh $download_url
chmod +x oh-my-posh
sudo mv oh-my-posh /usr/bin

echo "installing fzf"
# Download and install the latest release of fzf
latest_release_info=$(curl -s https://api.github.com/repos/junegunn/fzf/releases/latest | sed 's/[^[:print:]\t]//g')
download_url=$(echo "$latest_release_info" | grep -o 'https://github.com/junegunn/fzf/releases/download/[^"]*linux_amd64.tar.gz')
curl -L -o fzf.tar.gz $download_url
tar -xzf fzf.tar.gz
rm fzf.tar.gz
chmod +x fzf
sudo mv fzf /usr/bin

echo "installing neovim"
# Download and install the latest release of neovim
latest_release_info=$(curl -s https://api.github.com/repos/neovim/neovim/releases/latest)
download_url=$(echo "$latest_release_info" | grep -o 'https://github.com/neovim/neovim/releases/download/[^"]*nvim-linux64.tar.gz' | head -n 1)
curl -L -o nvim-linux64.tar.gz $download_url
tar xzf nvim-linux64.tar.gz
sudo mv nvim-linux64 /opt/nvim
sudo ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim
rm nvim-linux64.tar.gz

echo "Cloning nvchad"
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
    echo "Updating $plugin_name..."
    git -C "$PLUGIN_DIR/$plugin_name" pull
  else
    echo "Cloning $plugin_name..."
    git clone https://github.com/$plugin "$PLUGIN_DIR/$plugin_name"
  fi
done

echo "installing tmux plugins..."
$HOME/.tmux/plugins/tpm/scripts/install_plugins.sh
echo "installation completed. close the terminal"
