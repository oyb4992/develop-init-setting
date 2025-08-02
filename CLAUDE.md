# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A comprehensive development environment configuration repository for macOS and Windows systems. This repository provides infrastructure-as-code for setting up a complete developer workstation including terminal configurations, editors, window management, and productivity tools through dotfiles and automated installation scripts.

## Architecture

### Core Components

- **Master Installation Script** (`scripts/install.sh`): Orchestrates Homebrew installation, Brewfile execution, and tool configuration
- **Package Management** (`packages/Brewfile`): Homebrew bundle file containing all CLI tools and applications  
- **Configuration Directory** (`config/`): Organized configuration files by category:
  - **Terminal Configuration** (`config/terminals/`): Zsh, Kitty, iTerm2 setup
  - **Editor Configuration** (`config/editors/`): Neovim, LazyVim, VS Code, and IDE configurations
  - **System Configuration** (`config/system/`): System-level tools and MCP server settings
  - **Productivity Tools** (`config/productivity/`): PopClip, BetterTouchTool workflows, AutoHotKey scripts
  - **Window Management** (`config/window-managers/`): GlazeWM and tiling configurations
- **Services Directory** (`services/`): Docker Compose configurations for development services (LobeChat)

### Development Tools Stack

This repository configures:
- **Editors**: Neovim with LazyVim distribution, VS Code integration
- **Terminal**: Kitty terminal with custom configuration, iTerm2 settings
- **Shell**: Zsh with Oh-My-Zsh, powerlevel10k theme, syntax highlighting, autosuggestions
- **Version Control**: Git with git-flow extensions
- **Container Tools**: Docker, Docker Compose, Colima
- **Cloud Tools**: AWS CLI, Kubernetes CLI, Azure CLI
- **Languages**: Node.js, Python 3.13 (via uv), .NET 8, Ruby (rbenv), mise for version management

### Platform-Specific Features

**macOS:**
- Advanced key remapping via Karabiner-Elements (CapsLock as Hyper key)
- Application launching and productivity via Raycast
- Text manipulation via PopClip
- System automation via Hammerspoon
- Gesture customization via BetterTouchTool

**Windows:**
- Tiling window management via GlazeWM
- Status bar integration via Zebar
- Workspace-based application organization

## Essential Commands

### Initial Setup
```bash
# Complete environment setup
./scripts/install.sh

# Individual component installation
./config/terminals/zsh/install.sh           # Zsh configuration only
./config/terminals/kitty/install.sh         # Terminal configuration
./config/terminals/iterm2/install.sh        # iTerm2 profiles
```

### Package Management
```bash
# Install/update all packages
brew bundle --file=./packages/Brewfile

# Check outdated packages
brew outdated

# Update all packages
brew upgrade

# Clean up old packages
brew cleanup
```

### Development Tools

**Raycast Extension Development:**
```bash
cd config/productivity/raycast/raycast_command/[extension-name]
npm run build      # Build extension for production
npm run dev        # Development mode with hot reload
npm run lint       # Code linting
npm run fix-lint   # Auto-fix linting issues

# Available extensions: Naver-Dictionary, custom scripts
```

**Neovim Configuration:**
```bash
# Plugin management (handled automatically by init.vim)
:PlugInstall    # Install plugins
:PlugUpdate     # Update plugins
:PlugClean      # Remove unused plugins

# LazyVim commands
:Lazy           # Open LazyVim plugin manager
:LazyHealth     # Check LazyVim health
```

### Configuration Management
```bash
# Reload configurations
# Kitty: Ctrl+A > Shift+R in terminal
# Hammerspoon: Automatically reloads on file change

# Edit configurations
nvim ~/.config/kitty/kitty.conf           # Kitty terminal
nvim ~/.config/nvim/init.vim              # Neovim configuration  
nvim ~/.config/karabiner/karabiner.json   # Keyboard remapping
nvim ~/.hammerspoon/init.lua              # System automation

# Local repository configurations
nvim config/terminals/kitty/kitty.conf    # Repository Kitty config
nvim config/editors/init.vim              # Repository Neovim config
```

## Key Configuration Details

### Keyboard Shortcuts (macOS)
- **CapsLock**: Escape (tap) or Hyper key (hold)
- **Hyper + Space**: Language switching
- **Ctrl+A prefix**: Kitty window/tab management (tmux-style)

### Terminal Features (Kitty)
- **Ctrl+A > C**: New tab in current directory
- **Ctrl+A > X**: Close window
- **Ctrl+A > ,**: Rename tab
- **Ctrl+A > Space**: Hint mode for text selection
- **Ctrl+Shift+T**: Horizontal split
- **Ctrl+Shift+N**: New tab with nvim

### Window Management (Windows - GlazeWM)
- **Alt + [A-Z]**: Switch workspace (A=AI, B=Browser, I=IDE, T=Terminal, etc.)
- **Alt + Shift + [A-Z]**: Move window to workspace
- **Alt + H/L**: Focus left/right window
- **Alt + Shift + Space**: Toggle floating mode

### Hammerspoon Automation (macOS)
- **Power-aware caffeine control**: Automatic screen management based on power state
- **WiFi-based Bluetooth automation**: Auto-enable/disable Bluetooth based on network
- **Developer utilities**: Text case conversion, encoding/decoding, JSON formatting
- **BTT lifecycle management**: Automatic BetterTouchTool management

## Development Workflows

### Environment Setup Workflow
```bash
# 1. Clone and setup
git clone <repo> && cd dev-init-setting
./scripts/install.sh

# 2. Post-installation verification
brew doctor
kitty --version
nvim --version
```

### Daily Development Workflow
1. **Environment**: Use configured terminal, editor, and shortcuts
2. **Package Updates**: Regular `brew upgrade` to keep tools current
3. **Configuration Changes**: Edit files in `config/` directories and reload
4. **Extension Development**: Build and test Raycast extensions in `config/productivity/raycast/raycast_command/`

### System Maintenance
```bash
# Update all packages
brew upgrade && brew cleanup

# Update Neovim plugins  
nvim +PlugUpdate +qa

# Rebuild all Raycast extensions
find config/productivity/raycast/raycast_command -name package.json -execdir npm run build \;
```

## Architecture Notes

### File Organization Principles
- **Tool-specific directories**: Each application maintains its own configuration directory
- **Independent installation scripts**: Self-contained setup scripts per component
- **Modular configuration**: Environment-specific settings are isolated
- **Development-ready**: Build scripts and development workflows included for custom extensions

### Security Considerations
The installation script removes quarantine attributes from Homebrew cask-installed applications to prevent macOS security prompts. This is standard practice for development environment setup but should be noted for security awareness. Application list maintained in `packages/apps.txt`.

### Configuration File Locations

**System Locations:**
- **Kitty**: `~/.config/kitty/kitty.conf`
- **Neovim**: `~/.config/nvim/init.vim`
- **Karabiner**: `~/.config/karabiner/karabiner.json`
- **Hammerspoon**: `~/.hammerspoon/init.lua`
- **Zsh**: `~/.zshrc`

**Repository Structure:**
- **Terminals**: `config/terminals/` (kitty, zsh, iterm2)
- **Editors**: `config/editors/` (neovim, vscode, ideavim)
- **System Tools**: `config/system/` (mcp-server, fastfetch)
- **Productivity**: `config/productivity/` (raycast, popclip, btt-workflow)
- **Window Managers**: `config/window-managers/` (glazewm)

### Extension Development
Raycast extensions are TypeScript/JavaScript projects with full development workflows including build, lint, and development modes. Each extension maintains its own `package.json` with appropriate scripts for the development lifecycle.