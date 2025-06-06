#!/bin/bash
# Improved dotfiles deployment script

set -e  # Exit on error

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
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

main() {
    log "Starting dotfiles deployment from $DOTFILES_DIR"
    
    # Deploy configuration files
    for file in .bashrc .zshrc; do
        if [ -f "$DOTFILES_DIR/$file" ]; then
            create_symlink "$DOTFILES_DIR/$file" "$HOME/$file"
        fi
    done
    
    # Handle matplotlib config
    if [ -f "$DOTFILES_DIR/matplotlibrc" ]; then
        mkdir -p "$HOME/.matplotlib"
        if [ ! -f "$HOME/.matplotlib/matplotlibrc" ]; then
            cp "$DOTFILES_DIR/matplotlibrc" "$HOME/.matplotlib/matplotlibrc"
            log "Copied matplotlibrc to ~/.matplotlib/"
        else
            log "matplotlib config already exists, skipping"
        fi
    fi
    
    
    log "Deployment completed successfully"
    if [ -d "$BACKUP_DIR" ]; then
        log "Backups stored in: $BACKUP_DIR"
    fi
}

# Run main function
main "$@"
