#!/bin/zsh
# Zsh configuration - Modern & Minimal

# Get directory of this script (resolve symlinks)
DOTFILES_DIR="$(cd "$(dirname "$(readlink "${(%):-%N}" || echo "${(%):-%N}")")" && pwd)"

# Language settings (set early)
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# =============================================================================
# Zsh Plugin Manager (zinit)
# =============================================================================
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Auto-install zinit if not present
if [[ ! -d "$ZINIT_HOME" ]]; then
    print -P "%F{33}Installing zinit...%f"
    command mkdir -p "$(dirname $ZINIT_HOME)"
    command git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME" && \
        print -P "%F{34}Installation successful.%f" || \
        print -P "%F{160}Clone failed.%f"
fi

source "${ZINIT_HOME}/zinit.zsh"

# =============================================================================
# Zsh Plugins
# =============================================================================
# Syntax highlighting (must be loaded first)
zinit light zsh-users/zsh-syntax-highlighting

# Auto-suggestions based on history
zinit light zsh-users/zsh-autosuggestions

# Better completion
zinit light zsh-users/zsh-completions

# History substring search (type and use up/down arrows)
zinit light zsh-users/zsh-history-substring-search

# =============================================================================
# Source common shell configuration
# =============================================================================
source "$DOTFILES_DIR/shell/common.sh"

# =============================================================================
# Zsh-specific settings
# =============================================================================
autoload -Uz colors && colors

# Completion settings
autoload -U compinit && compinit
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'  # Case-insensitive completion
zstyle ':completion:*' cache-path ~/.zsh/cache

# History settings
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt EXTENDED_HISTORY       # Write timestamp to history
setopt HIST_EXPIRE_DUPS_FIRST # Expire duplicates first
setopt HIST_IGNORE_DUPS       # Don't record duplicates
setopt HIST_IGNORE_SPACE      # Don't record commands starting with space
setopt HIST_VERIFY            # Show command before executing from history
setopt SHARE_HISTORY          # Share history between sessions

# Key bindings for history-substring-search
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^P' history-substring-search-up
bindkey '^N' history-substring-search-down

# Other useful options
setopt AUTO_CD                # cd by just typing directory name
setopt AUTO_PUSHD             # Push directory to stack on cd
setopt PUSHD_IGNORE_DUPS      # Don't push duplicate directories
setopt CORRECT                # Command correction suggestions

# =============================================================================
# Tool Initializations (order matters!)
# =============================================================================

# Starship prompt (modern cross-shell prompt)
if type starship > /dev/null 2>&1; then
    eval "$(starship init zsh)"
else
    # Fallback prompt if starship not installed
    PROMPT="%{$fg[yellow]%}%n@"
    PROMPT+="%{$fg[cyan]%}%m "
    PROMPT+="%{$fg[magenta]%}%~ "
    PROMPT+="%{$reset_color%}$ "
fi

# zoxide (smarter cd replacement)
if type zoxide > /dev/null 2>&1; then
    eval "$(zoxide init zsh)"
fi

# fzf integration
if type fzf > /dev/null 2>&1; then
    # Try to source fzf completion and key-bindings
    [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
    # Homebrew fzf
    [ -f /opt/homebrew/opt/fzf/shell/completion.zsh ] && source /opt/homebrew/opt/fzf/shell/completion.zsh
    [ -f /opt/homebrew/opt/fzf/shell/key-bindings.zsh ] && source /opt/homebrew/opt/fzf/shell/key-bindings.zsh
    # Linuxbrew fzf
    [ -f /home/linuxbrew/.linuxbrew/opt/fzf/shell/completion.zsh ] && source /home/linuxbrew/.linuxbrew/opt/fzf/shell/completion.zsh
    [ -f /home/linuxbrew/.linuxbrew/opt/fzf/shell/key-bindings.zsh ] && source /home/linuxbrew/.linuxbrew/opt/fzf/shell/key-bindings.zsh
fi

# atuin (better shell history with SQLite + fuzzy search)
if type atuin > /dev/null 2>&1; then
    eval "$(atuin init zsh --disable-up-arrow)"
    # Ctrl+R for atuin search (replaces default history search)
fi

# ghq + fzf: Ctrl+G to jump to repository
if type ghq > /dev/null 2>&1 && type fzf > /dev/null 2>&1; then
    function ghq-fzf-widget() {
        local repo=$(ghq list | fzf --height 40% --reverse --preview "ls -la $(ghq root)/{}")
        if [ -n "$repo" ]; then
            BUFFER="cd $(ghq root)/$repo"
            zle accept-line
        fi
        zle reset-prompt
    }
    zle -N ghq-fzf-widget
    bindkey '^G' ghq-fzf-widget
fi

# direnv
if type direnv > /dev/null 2>&1; then
    eval "$(direnv hook zsh)"
fi

# =============================================================================
# PATH additions
# =============================================================================
export PATH="$HOME/.claude/local:$PATH"
export PATH="$HOME/.antigravity/antigravity/bin:$PATH"

# =============================================================================
# Aliases
# =============================================================================
alias claude="$HOME/.claude/local/claude"
