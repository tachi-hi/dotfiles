#!/bin/bash
# Modern dotfiles deployment script
# Supports: shell configs, git, starship, and other modern CLI tools

set -e  # Exit on error

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    echo -e "${GREEN}[$(date '+%H:%M:%S')]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[$(date '+%H:%M:%S')] WARNING:${NC} $1"
}

log_info() {
    echo -e "${BLUE}[$(date '+%H:%M:%S')] INFO:${NC} $1"
}

backup_file() {
    local file="$1"
    if [ -f "$file" ] && [ ! -L "$file" ]; then
        mkdir -p "$BACKUP_DIR"
        cp "$file" "$BACKUP_DIR/"
        log "Backed up $file to $BACKUP_DIR/"
    fi
}

create_symlink() {
    local source="$1"
    local target="$2"
    
    if [ -L "$target" ]; then
        local current_target=$(readlink "$target")
        if [ "$current_target" = "$source" ]; then
            log "Symlink $target already points to $source, skipping"
            return
        fi
    fi
    
    if [ -e "$target" ]; then
        backup_file "$target"
        rm "$target"
    fi
    
    ln -sf "$source" "$target"
    log "Created symlink: $target -> $source"
}

append_source_line() {
    local file="$1"
    local source_line="$2"
    
    if [ -f "$file" ]; then
        if grep -Fxq "$source_line" "$file"; then
            log "Source line already exists in $file, skipping"
            return
        fi
        backup_file "$file"
        echo "" >> "$file"
        echo "# Added by dotfiles deploy script" >> "$file"
        echo "$source_line" >> "$file"
        log "Appended source line to $file"
    else
        echo "$source_line" > "$file"
        log "Created $file with source line"
    fi
}

deploy_gitconfig() {
    local gitconfig_source="$DOTFILES_DIR/.gitconfig"
    local gitconfig_target="$HOME/.gitconfig"
    local gitconfig_local="$HOME/.gitconfig.local"

    if [ ! -f "$gitconfig_source" ]; then
        return
    fi

    # If existing ~/.gitconfig has user settings, extract them to .gitconfig.local
    if [ -f "$gitconfig_target" ] && [ ! -L "$gitconfig_target" ]; then
        log_info "Found existing ~/.gitconfig, extracting user settings..."

        # Extract [user] section if exists and .gitconfig.local doesn't exist
        if [ ! -f "$gitconfig_local" ]; then
            local user_name=$(git config --global --get user.name 2>/dev/null || true)
            local user_email=$(git config --global --get user.email 2>/dev/null || true)
            local user_signingkey=$(git config --global --get user.signingkey 2>/dev/null || true)

            if [ -n "$user_name" ] || [ -n "$user_email" ]; then
                log "Migrating user settings to ~/.gitconfig.local"
                echo "# Local git config (not tracked in dotfiles)" > "$gitconfig_local"
                echo "# This file is included by ~/.gitconfig" >> "$gitconfig_local"
                echo "" >> "$gitconfig_local"
                echo "[user]" >> "$gitconfig_local"
                [ -n "$user_name" ] && echo "    name = $user_name" >> "$gitconfig_local"
                [ -n "$user_email" ] && echo "    email = $user_email" >> "$gitconfig_local"
                [ -n "$user_signingkey" ] && echo "    signingkey = $user_signingkey" >> "$gitconfig_local"
                log "Created ~/.gitconfig.local with your user settings"
            fi
        else
            log "~/.gitconfig.local already exists, preserving it"
        fi
    fi

    # Now create symlink for .gitconfig
    create_symlink "$gitconfig_source" "$gitconfig_target"

    # Remind user about .gitconfig.local
    if [ ! -f "$gitconfig_local" ]; then
        log_warn "Don't forget to create ~/.gitconfig.local with your [user] settings:"
        echo -e "    ${BLUE}git config --global user.name \"Your Name\"${NC}"
        echo -e "    ${BLUE}git config --global user.email \"your@email.com\"${NC}"
    fi
}

check_tools() {
    log_info "Checking for recommended tools..."
    echo ""

    local missing_tools=()
    local tools=(
        "starship:Starship (prompt)"
        "fzf:fzf (fuzzy finder)"
        "bat:bat (better cat)"
        "eza:eza (better ls)"
        "fd:fd (better find)"
        "rg:ripgrep (better grep)"
        "zoxide:zoxide (smarter cd)"
        "delta:delta (better git diff)"
        "ghq:ghq (repo manager)"
        "lazygit:lazygit (TUI git)"
        "atuin:atuin (history search)"
        "direnv:direnv (env per dir)"
    )

    for tool_info in "${tools[@]}"; do
        local cmd="${tool_info%%:*}"
        local name="${tool_info#*:}"
        if command -v "$cmd" > /dev/null 2>&1; then
            echo -e "  ${GREEN}✓${NC} $name"
        else
            echo -e "  ${RED}✗${NC} $name"
            missing_tools+=("$cmd")
        fi
    done

    echo ""
    if [ ${#missing_tools[@]} -gt 0 ]; then
        log_warn "Some tools are missing. Run install.sh or install manually:"
        echo ""
        echo -e "  ${BLUE}./install.sh${NC}  # Cross-platform installer"
        echo -e "  ${BLUE}brew install ${missing_tools[*]}${NC}  # Homebrew"
        echo ""
    else
        log "All recommended tools are installed!"
    fi
}

main() {
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║     Modern Dotfiles Deployment         ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    echo ""

    log "Starting deployment from $DOTFILES_DIR"

    # Deploy shell configuration files
    for file in .bashrc .zshrc; do
        if [ -f "$DOTFILES_DIR/$file" ]; then
            create_symlink "$DOTFILES_DIR/$file" "$HOME/$file"
        fi
    done

    # Handle .gitconfig specially (preserve user settings)
    deploy_gitconfig

    # Handle matplotlib config (symlink)
    if [ -f "$DOTFILES_DIR/.matplotlib/matplotlibrc" ]; then
        mkdir -p "$HOME/.matplotlib"
        create_symlink "$DOTFILES_DIR/.matplotlib/matplotlibrc" "$HOME/.matplotlib/matplotlibrc"
    fi

    # Handle .config directory (starship, git ignore, etc.)
    if [ -d "$DOTFILES_DIR/.config" ]; then
        mkdir -p "$HOME/.config"
        find "$DOTFILES_DIR/.config" -type f | while read -r file; do
            relative_path="${file#$DOTFILES_DIR/.config/}"
            target_dir="$HOME/.config/$(dirname "$relative_path")"
            mkdir -p "$target_dir"
            create_symlink "$file" "$HOME/.config/$relative_path"
        done
    fi

    echo ""
    log "Deployment completed successfully!"

    if [ -d "$BACKUP_DIR" ]; then
        log "Backups stored in: $BACKUP_DIR"
    fi

    echo ""
    check_tools

    echo -e "${YELLOW}NOTE:${NC} Restart your shell or run 'source ~/.zshrc' to apply changes."
    echo ""
}

# Run main function
main "$@"
