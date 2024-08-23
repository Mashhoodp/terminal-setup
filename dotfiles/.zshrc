# Load plugins
source ~/.config/zsh/zsh-completions/src
source ~/.config/zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.config/zsh/fzf-tab/fzf-tab.plugin.zsh
source ~/.config/zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Load completions
autoload -Uz compinit && compinit


# oh-my-posh initilisation
eval "$(oh-my-posh init zsh --config ~/.config/ohmyposh/zen.toml)" 

# Keybindings
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region

# History
HISTSIZE=8000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'

# Aliases
alias ls='ls --color'
alias vim='nvim'
alias c='clear'
alias e='exit'
alias ll='ls -l'
alias la='ls -a'
alias lla='ls -la'
alias l='ls -CF'
alias bat='batcat'

# Shell integrations
eval "$(fzf --zsh)"
