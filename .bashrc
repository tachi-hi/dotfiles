#!/bin/bash
# Bash configuration

# Get directory of this script (resolve symlinks)
DOTFILES_DIR="$(cd "$(dirname "$(readlink "${BASH_SOURCE[0]}" || echo "${BASH_SOURCE[0]}")")" && pwd)"

# Source common shell configuration
source "$DOTFILES_DIR/shell/common.sh"

# Bash-specific prompt (optimized for dark background)
export PS1="\[\e[33;1m\]\u\[\e[00m\]@\[\e[36;1m\]\H\[\e[00m\] \[\e[35;1m\]\w/\[\e[00m\]\$ "
