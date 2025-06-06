#!/bin/zsh
# Zsh configuration

# Get directory of this script (resolve symlinks)
DOTFILES_DIR="$(cd "$(dirname "$(readlink "${(%):-%N}" || echo "${(%):-%N}")")" && pwd)"

# Source common shell configuration
source "$DOTFILES_DIR/shell/common.sh"

# Zsh-specific settings
autoload -Uz colors
colors

# Zsh-specific prompt (optimized for dark background)
PROMPT="%{$fg[yellow]%}%n@"
PROMPT+="%{$fg[cyan]%}%m "
PROMPT+="%{$fg[magenta]%}%~ "
PROMPT+="%{$reset_color%}$ "

# Language settings
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# Enable completion colors matching ls colors
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
