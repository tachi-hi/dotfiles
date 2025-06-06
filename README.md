# dotfiles

A clean and modular dotfiles configuration for bash and zsh shells.

## Features

- **Modular design**: Common functionality shared between bash and zsh
- **Safe deployment**: Automatic backup of existing files
- **Duplicate prevention**: Intelligent handling of existing configurations
- **Cross-platform**: Works on both macOS and Linux

## Structure

```
dotfiles/
├── shell/
│   └── common.sh          # Shared shell configuration
├── .bashrc               # Bash-specific configuration
├── .zshrc                # Zsh-specific configuration
├── matplotlibrc          # Matplotlib configuration
├── deploy.sh             # Deployment script
└── README.md
```

## Installation

1. Clone this repository to your home directory:
   ```bash
   cd ~
   git clone <your-repo-url> dotfiles
   ```

2. Run the deployment script:
   ```bash
   cd dotfiles
   ./deploy.sh
   ```

The script will:
- Create symbolic links for shell configuration files
- Copy matplotlib configuration to ~/.matplotlib/
- Backup existing files automatically
- Skip files that are already correctly configured

## What's Included

### Common Features (bash & zsh)
- PATH deduplication and management
- Homebrew path configuration
- Enhanced color support for `ls` and `diff` commands (cross-platform)
- GNU coreutils integration on macOS (if installed)
- Modern `exa` integration (if installed)
- Useful aliases

### Shell-Specific Features
- **Bash**: Custom colored prompt
- **Zsh**: Colored prompt with UTF-8 locale settings, enhanced completion colors

### Additional Features
- **Matplotlib**: Configuration for Python plotting library

## Customization

To add new common functionality, edit `shell/common.sh`.
For shell-specific settings, edit `.bashrc` or `.zshrc` respectively.

## Safety Features

- Automatic backup of existing files
- Duplicate detection to prevent redundant configurations
- Symlink verification to avoid conflicts
- Detailed logging of all operations

## Removed Legacy Features

This refactored version removes:
- CUDA-related configurations (outdated)
- Automatic virtual environment activation
- Redundant PATH additions
- Commented-out legacy code
