#!/bin/bash
# Cross-platform dotfiles installer
# Supports: macOS (Homebrew) and Linux (apt/Homebrew)

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${GREEN}[*]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[!]${NC} $1"; }
log_error() { echo -e "${RED}[x]${NC} $1"; }
log_info() { echo -e "${BLUE}[i]${NC} $1"; }

# Detect OS
detect_os() {
    case "$(uname -s)" in
        Darwin*) echo "macos" ;;
        Linux*)  echo "linux" ;;
        *)       echo "unknown" ;;
    esac
}

# Detect Linux distribution
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$ID"
    else
        echo "unknown"
    fi
}

# Install Homebrew if not present
install_homebrew() {
    if ! command -v brew &> /dev/null; then
        log "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # Add to PATH for this session
        if [ "$(detect_os)" = "linux" ]; then
            eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        fi
    else
        log "Homebrew already installed"
    fi
}

# Install packages via Homebrew
install_with_brew() {
    log "Installing packages via Homebrew..."
    brew bundle --file="$DOTFILES_DIR/Brewfile" || true
}

# Install packages via apt (Debian/Ubuntu)
install_with_apt() {
    log "Installing packages via apt..."

    sudo apt update

    # Core tools available via apt
    sudo apt install -y \
        zsh \
        git \
        curl \
        wget \
        jq \
        tree \
        htop \
        direnv

    # Install modern CLI tools (may need PPAs or manual install)
    log_info "Installing modern CLI tools..."

    # eza (ls replacement)
    if ! command -v eza &> /dev/null; then
        sudo apt install -y gpg
        sudo mkdir -p /etc/apt/keyrings
        wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
        echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
        sudo apt update
        sudo apt install -y eza
    fi

    # bat
    sudo apt install -y bat || sudo apt install -y batcat
    # Create symlink if installed as batcat
    if command -v batcat &> /dev/null && ! command -v bat &> /dev/null; then
        mkdir -p ~/.local/bin
        ln -sf "$(which batcat)" ~/.local/bin/bat
    fi

    # fd-find
    sudo apt install -y fd-find || true
    if command -v fdfind &> /dev/null && ! command -v fd &> /dev/null; then
        mkdir -p ~/.local/bin
        ln -sf "$(which fdfind)" ~/.local/bin/fd
    fi

    # ripgrep
    sudo apt install -y ripgrep || true

    # fzf
    if ! command -v fzf &> /dev/null; then
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
        ~/.fzf/install --all --no-update-rc
    fi

    # starship
    if ! command -v starship &> /dev/null; then
        curl -sS https://starship.rs/install.sh | sh -s -- -y
    fi

    # zoxide
    if ! command -v zoxide &> /dev/null; then
        curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
    fi

    # delta
    if ! command -v delta &> /dev/null; then
        log_info "Installing delta..."
        DELTA_VERSION=$(curl -s https://api.github.com/repos/dandavison/delta/releases/latest | jq -r .tag_name)
        curl -Lo /tmp/delta.deb "https://github.com/dandavison/delta/releases/download/${DELTA_VERSION}/git-delta_${DELTA_VERSION}_amd64.deb"
        sudo dpkg -i /tmp/delta.deb || sudo apt install -f -y
        rm /tmp/delta.deb
    fi

    # gh (GitHub CLI)
    if ! command -v gh &> /dev/null; then
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list
        sudo apt update
        sudo apt install gh -y
    fi

    # ghq
    if ! command -v ghq &> /dev/null; then
        log_info "Installing ghq..."
        GHQ_VERSION=$(curl -s https://api.github.com/repos/x-motemen/ghq/releases/latest | jq -r .tag_name | tr -d 'v')
        curl -Lo /tmp/ghq.zip "https://github.com/x-motemen/ghq/releases/download/v${GHQ_VERSION}/ghq_linux_amd64.zip"
        unzip -o /tmp/ghq.zip -d /tmp/ghq
        sudo mv /tmp/ghq/ghq_linux_amd64/ghq /usr/local/bin/
        rm -rf /tmp/ghq /tmp/ghq.zip
    fi

    # lazygit
    if ! command -v lazygit &> /dev/null; then
        log_info "Installing lazygit..."
        LAZYGIT_VERSION=$(curl -s https://api.github.com/repos/jesseduffield/lazygit/releases/latest | jq -r .tag_name | tr -d 'v')
        curl -Lo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
        tar -xzf /tmp/lazygit.tar.gz -C /tmp
        sudo mv /tmp/lazygit /usr/local/bin/
        rm /tmp/lazygit.tar.gz
    fi

    # atuin
    if ! command -v atuin &> /dev/null; then
        curl -sS https://raw.githubusercontent.com/atuinsh/atuin/main/install.sh | bash
    fi
}

# Install Nerd Fonts (Linux)
install_nerd_fonts_linux() {
    log_info "Installing Nerd Fonts..."
    mkdir -p ~/.local/share/fonts

    local fonts=("Hack" "JetBrainsMono" "FiraCode")
    for font in "${fonts[@]}"; do
        if [ ! -d ~/.local/share/fonts/"$font" ]; then
            curl -Lo /tmp/"$font".zip "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/$font.zip"
            unzip -o /tmp/"$font".zip -d ~/.local/share/fonts/"$font"
            rm /tmp/"$font".zip
        fi
    done

    fc-cache -fv
}

# Configure terminal fonts (macOS)
configure_terminal_fonts_macos() {
    log_info "Configuring terminal fonts..."

    local FONT_NAME="HackNerdFontMono-Regular"
    local FONT_SIZE=12

    # Terminal.app configuration
    if [ -d "/Applications/Utilities/Terminal.app" ]; then
        log "Configuring Terminal.app font..."

        # Get current profile name
        local TERMINAL_PROFILE=$(defaults read com.apple.Terminal "Default Window Settings" 2>/dev/null || echo "Basic")

        # Set font for the profile
        defaults write com.apple.Terminal "Window Settings" -dict-add "$TERMINAL_PROFILE" \
            "<dict>
                <key>Font</key>
                <data>$(printf '\x00\x00\x00\x00')</data>
            </dict>" 2>/dev/null || true

        # Use plutil to set font (more reliable)
        /usr/libexec/PlistBuddy -c "Set ':Window Settings:$TERMINAL_PROFILE:Font' -data '$(echo -n "bplist00" | base64)'" ~/Library/Preferences/com.apple.Terminal.plist 2>/dev/null || true

        log_info "Terminal.app: Please manually set font to 'Hack Nerd Font Mono' in Preferences > Profiles > Text > Font"
    fi

    # iTerm2 configuration
    if [ -d "/Applications/iTerm.app" ]; then
        log "Configuring iTerm2 font..."

        # Set font for default profile
        defaults write com.googlecode.iterm2 "New Bookmarks" -array-add '{
            "Normal Font" = "HackNerdFontMono-Regular 12";
        }' 2>/dev/null || true

        # Alternative: Set via preferences
        /usr/libexec/PlistBuddy -c "Set ':New Bookmarks:0:Normal Font' 'HackNerdFontMono-Regular 12'" \
            ~/Library/Preferences/com.googlecode.iterm2.plist 2>/dev/null || \
        /usr/libexec/PlistBuddy -c "Add ':New Bookmarks:0:Normal Font' string 'HackNerdFontMono-Regular 12'" \
            ~/Library/Preferences/com.googlecode.iterm2.plist 2>/dev/null || true

        log "iTerm2 font configured to Hack Nerd Font Mono"
    fi

    # VS Code configuration
    local VSCODE_SETTINGS="$HOME/Library/Application Support/Code/User/settings.json"
    if [ -d "/Applications/Visual Studio Code.app" ] || [ -d "$HOME/Applications/Visual Studio Code.app" ]; then
        log "Configuring VS Code terminal font..."

        if [ -f "$VSCODE_SETTINGS" ]; then
            # Check if terminal.integrated.fontFamily is already set
            if ! grep -q "terminal.integrated.fontFamily" "$VSCODE_SETTINGS" 2>/dev/null; then
                # Use jq if available, otherwise provide manual instructions
                if command -v jq &> /dev/null; then
                    local tmp=$(mktemp)
                    jq '. + {"terminal.integrated.fontFamily": "'\''Hack Nerd Font Mono'\''", "terminal.integrated.fontSize": 12}' "$VSCODE_SETTINGS" > "$tmp" && mv "$tmp" "$VSCODE_SETTINGS"
                    log "VS Code terminal font configured"
                else
                    log_info "VS Code: Add to settings.json:"
                    echo '  "terminal.integrated.fontFamily": "'\''Hack Nerd Font Mono'\''"'
                fi
            else
                log "VS Code terminal font already configured"
            fi
        else
            # Create settings file if it doesn't exist
            mkdir -p "$(dirname "$VSCODE_SETTINGS")"
            echo '{
    "terminal.integrated.fontFamily": "'\''Hack Nerd Font Mono'\''",
    "terminal.integrated.fontSize": 12
}' > "$VSCODE_SETTINGS"
            log "VS Code settings.json created with Nerd Font"
        fi
    fi

    # WezTerm configuration
    local WEZTERM_CONFIG="$HOME/.wezterm.lua"
    if command -v wezterm &> /dev/null || [ -d "/Applications/WezTerm.app" ]; then
        if [ ! -f "$WEZTERM_CONFIG" ]; then
            log "Creating WezTerm configuration..."
            cat > "$WEZTERM_CONFIG" << 'EOF'
local wezterm = require 'wezterm'
local config = {}

-- Font configuration
config.font = wezterm.font('Hack Nerd Font Mono')
config.font_size = 14.0

-- Color scheme
config.color_scheme = 'Dracula'

return config
EOF
            log "WezTerm config created at ~/.wezterm.lua"
        else
            log "WezTerm config already exists, skipping"
        fi
    fi

    echo ""
    log_info "Font configuration summary:"
    echo "  - Nerd Fonts installed via Homebrew"
    echo "  - Terminal apps configured where possible"
    echo ""
    log_warn "If icons still show as '?', restart your terminal app"
    log_warn "and verify the font is set to 'Hack Nerd Font Mono'"
}

# Main installation
main() {
    local os=$(detect_os)
    local distro=$(detect_distro)

    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║     Dotfiles Package Installer         ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    echo ""

    log_info "Detected OS: $os"
    [ "$os" = "linux" ] && log_info "Detected distro: $distro"

    case "$os" in
        macos)
            install_homebrew
            install_with_brew
            configure_terminal_fonts_macos
            ;;
        linux)
            echo ""
            log_info "Choose installation method:"
            echo "  1) Homebrew (recommended - same tools as macOS)"
            echo "  2) apt + manual installs (native Linux packages)"
            echo ""
            read -p "Enter choice [1/2]: " choice

            case "$choice" in
                1)
                    install_homebrew
                    install_with_brew
                    ;;
                2)
                    install_with_apt
                    install_nerd_fonts_linux
                    ;;
                *)
                    log_error "Invalid choice"
                    exit 1
                    ;;
            esac
            ;;
        *)
            log_error "Unsupported OS: $os"
            exit 1
            ;;
    esac

    echo ""
    log "Package installation complete!"
    log_info "Now run: ./deploy.sh"
    echo ""
}

main "$@"
