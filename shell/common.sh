#!/bin/bash
# Common shell configuration for both bash and zsh

# PATH management - remove duplicates
_path=""
for _p in $(echo $PATH | tr ':' ' '); do
  case ":${_path}:" in
    *:"${_p}":* )
      ;;
    * )
      if [ "$_path" ]; then
        _path="$_path:$_p"
      else
        _path=$_p
      fi
      ;;
  esac
done
PATH=$_path
unset _p
unset _path

# Add Homebrew paths
PATH=$PATH:/opt/homebrew/bin/
PATH=$PATH:/opt/homebrew/anaconda3/bin/

# diff -> colordiff
if [[ -x `which colordiff` ]]; then
  alias diff='colordiff'
else
  alias diff='diff'
fi

# ls color configuration
if [ "$(uname)" = 'Darwin' ]; then
    # macOS - optimized for dark background
    export LSCOLORS=Gxfxcxdxbxegedabagacad
    alias ls='ls -G'
    
    # Use GNU coreutils if available (brew install coreutils)
    if command -v gls > /dev/null; then
        alias ls='gls --color=auto'
    fi
else
    # Linux - use standard colors
    alias ls='ls --color=auto'
fi

# Use dircolors if available for standard color support
if command -v dircolors > /dev/null; then
    if [ -r ~/.dircolors ]; then
        eval "$(dircolors -b ~/.dircolors)"
    else
        eval "$(dircolors -b)"
    fi
fi

# Basic aliases
alias sl='ls'
alias sudu='sudo du -h --max-depth=1 .'

# =============================================================================
# Modern CLI tools (explicit aliases - don't override standard commands)
# Standard commands (ls, cat, find, grep) remain unchanged for AI tools
# =============================================================================

# eza/exa - modern ls (human-friendly aliases)
if type eza > /dev/null 2>&1; then
    alias ll='eza -la --icons --group-directories-first'
    alias la='eza -a --icons --group-directories-first'
    alias lt='eza -T --icons --level=2'
    alias lta='eza -Ta --icons --level=2'
fi

# bat - syntax highlighting (explicit alias, don't override cat)
if type bat > /dev/null 2>&1; then
    alias cath='bat'  # cat with highlighting
    alias catp='bat --paging=always'
fi

# fd/rg - available directly, don't override find/grep

# zoxide (smarter cd)
if type zoxide > /dev/null 2>&1; then
    # Will be initialized in shell-specific config
    export _ZO_ECHO=1
fi

# fzf configuration (minimal)
if type fzf > /dev/null 2>&1; then
    export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"
    # Use fd for fzf if available
    if type fd > /dev/null 2>&1; then
        export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
        export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
    fi
fi

# delta (better git diff) - only enable if installed
if type delta > /dev/null 2>&1; then
    export GIT_PAGER="delta"
fi

# Useful functions (human use)
# fzf + cd
fcd() {
    local dir
    dir=$(fd --type d --hidden --follow --exclude .git 2>/dev/null | fzf +m) && cd "$dir"
}

# fzf + vim/editor
fv() {
    local file
    file=$(fzf --preview 'head -100 {}') && ${EDITOR:-vim} "$file"
}

# fzf + git log
fgl() {
    git log --oneline | fzf --preview 'git show {1}' | cut -d' ' -f1 | xargs git show
}

# Quick directory navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Safety aliases
alias rm='rm -i'
alias mv='mv -i'
alias cp='cp -i'

# =============================================================================
# ghq - Git repository manager
# =============================================================================
if type ghq > /dev/null 2>&1; then
    export GHQ_ROOT="$HOME/ghq"

    # ghq + fzf: Jump to repository with Ctrl+G (defined in shell-specific config)
    # Function to select repository
    ghq-fzf() {
        local repo
        repo=$(ghq list | fzf --preview "ls -la $(ghq root)/{}")
        if [ -n "$repo" ]; then
            cd "$(ghq root)/$repo"
        fi
    }

    # Quick clone
    alias get='ghq get'
fi

# =============================================================================
# lazygit - TUI Git client
# =============================================================================
if type lazygit > /dev/null 2>&1; then
    alias lg='lazygit'
    alias lzg='lazygit'
fi

# =============================================================================
# direnv - Directory-specific environment
# =============================================================================
if type direnv > /dev/null 2>&1; then
    # Hook is initialized in shell-specific config
    export DIRENV_LOG_FORMAT=""  # Suppress output
fi

# =============================================================================
# GitHub CLI
# =============================================================================
if type gh > /dev/null 2>&1; then
    alias pr='gh pr'
    alias issue='gh issue'
    alias repo='gh repo'
fi
