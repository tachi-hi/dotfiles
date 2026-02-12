#!/bin/bash
# Configure Terminal.app to use Hack Nerd Font Mono
# Run this after installing Nerd Fonts via: brew install --cask font-hack-nerd-font

set -e

FONT_NAME="HackNerdFontMono-Regular"
FONT_SIZE=12

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${GREEN}[*]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[!]${NC} $1"; }
log_info() { echo -e "${BLUE}[i]${NC} $1"; }

# Check if font is installed
check_font_installed() {
    if ! system_profiler SPFontsDataType 2>/dev/null | grep -q "Hack Nerd Font"; then
        log_warn "Hack Nerd Font not found. Installing..."
        brew install --cask font-hack-nerd-font
    else
        log "Hack Nerd Font is installed"
    fi
}

# Configure Terminal.app using AppleScript
configure_terminal_app() {
    log "Configuring Terminal.app..."

    # Get current default profile
    local PROFILE=$(defaults read com.apple.Terminal "Default Window Settings" 2>/dev/null || echo "Basic")
    log_info "Current profile: $PROFILE"

    # Use AppleScript to set the font
    osascript << EOF
tell application "Terminal"
    -- Get the default settings
    set defaultSettings to default settings

    -- Set font name and size
    set font name of defaultSettings to "Hack Nerd Font Mono"
    set font size of defaultSettings to ${FONT_SIZE}

    -- Also set for startup settings if different
    try
        set startupSettings to startup settings
        set font name of startupSettings to "Hack Nerd Font Mono"
        set font size of startupSettings to ${FONT_SIZE}
    end try
end tell
EOF

    if [ $? -eq 0 ]; then
        log "Terminal.app font configured successfully!"
        log_info "Font: Hack Nerd Font Mono, Size: ${FONT_SIZE}"
    else
        log_warn "AppleScript failed. Please set font manually:"
        echo ""
        echo "  1. Open Terminal.app"
        echo "  2. Go to Terminal > Settings (or Preferences)"
        echo "  3. Select your profile (e.g., Basic)"
        echo "  4. Click 'Change...' next to Font"
        echo "  5. Select 'Hack Nerd Font Mono', size 14"
        echo ""
    fi
}

# Restart Terminal reminder
show_restart_reminder() {
    echo ""
    log_warn "Please restart Terminal.app for changes to take effect."
    echo ""
    log_info "After restart, icons should display correctly:"
    echo "   Folder icon, Git branch icon, etc."
    echo ""
}

main() {
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║   Terminal.app Font Configuration      ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    echo ""

    check_font_installed
    configure_terminal_app
    show_restart_reminder
}

main "$@"
