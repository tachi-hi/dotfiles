# Brewfile - Modern CLI Tools
# Works on macOS and Linux (with Homebrew/Linuxbrew)
# Install with: brew bundle --file=~/dotfiles/Brewfile

# =============================================================================
# Core CLI Tools
# =============================================================================

# Shell
brew "zsh"

# Modern replacements
brew "eza"           # ls replacement (maintained fork of exa)
brew "bat"           # cat replacement with syntax highlighting
brew "fd"            # find replacement
brew "ripgrep"       # grep replacement
brew "zoxide"        # cd replacement (smart directory jumping)
brew "fzf"           # fuzzy finder
brew "git-delta"     # git diff viewer

# Prompt
brew "starship"      # cross-shell prompt

# =============================================================================
# Git & Repository Management
# =============================================================================
brew "git"
brew "gh"            # GitHub CLI
brew "ghq"           # git repository manager
brew "lazygit"       # TUI git client

# =============================================================================
# Shell Enhancements
# =============================================================================
brew "atuin"         # shell history search (SQLite based)
brew "direnv"        # directory-specific environment variables

# =============================================================================
# Development Tools
# =============================================================================
brew "jq"            # JSON processor
brew "yq"            # YAML processor
brew "tree"          # directory tree
brew "htop"          # process viewer
brew "tldr"          # simplified man pages
brew "httpie"        # modern curl alternative
brew "wget"

# =============================================================================
# Optional Tools (uncomment if needed)
# =============================================================================
# brew "neovim"      # modern vim
# brew "tmux"        # terminal multiplexer
# brew "mise"        # runtime version manager (asdf successor)
# brew "docker"
# brew "kubectl"

# =============================================================================
# macOS Only (casks) - automatically skipped on Linux
# =============================================================================
# Fonts (for terminal icons)
cask "font-hack-nerd-font" if OS.mac?
cask "font-jetbrains-mono-nerd-font" if OS.mac?
cask "font-fira-code-nerd-font" if OS.mac?

# Apps (optional - uncomment if needed)
# cask "wezterm" if OS.mac?
# cask "alacritty" if OS.mac?
# cask "iterm2" if OS.mac?
# cask "visual-studio-code" if OS.mac?
