#!/bin/bash
set -euo pipefail

echo "--- Starting macOS setup ---"

# Get the absolute path of the script's directory
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
MACOS_DIR=$SCRIPT_DIR
PROJECT_ROOT=$(dirname "$(dirname "$MACOS_DIR")")

link_file() {
    local source_path=$1
    local target_path=$2
    local target_dir

    target_dir=$(dirname "$target_path")
    mkdir -p "$target_dir"
    ln -sfv "$source_path" "$target_path"
}

link_path() {
    local source_path=$1
    local target_path=$2
    local target_dir
    local backup_path

    target_dir=$(dirname "$target_path")
    mkdir -p "$target_dir"

    if [ -L "$target_path" ] || [ -f "$target_path" ]; then
        ln -sfnv "$source_path" "$target_path"
    elif [ -e "$target_path" ]; then
        backup_path="${target_path}.backup.$(date +%Y%m%d%H%M%S)"
        echo "WARN: Existing path found at $target_path. Moving it to $backup_path"
        mv "$target_path" "$backup_path"
        ln -sfnv "$source_path" "$target_path"
    else
        ln -sfnv "$source_path" "$target_path"
    fi
}

# --- Homebrew Installation ---
if ! command -v brew &> /dev/null; then
    echo "Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    if [[ "$(uname -m)" == "arm64" ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
fi

# --- Brew Bundle Installation ---
echo "Installing packages from Brewfile..."
if [ -f "$MACOS_DIR/packages/Brewfile" ]; then
    brew bundle --file="$MACOS_DIR/packages/Brewfile"
else
    echo "ERROR: Brewfile not found at $MACOS_DIR/packages/Brewfile" >&2
    exit 1
fi

# --- Link macOS-specific configurations ---
echo "Linking macOS-specific configurations..."

# AeroSpace
link_file "$MACOS_DIR/config/.aerospace.toml" "$HOME/.aerospace.toml"

# Hammerspoon
mkdir -p "$HOME/.hammerspoon"
for lua_file in "$MACOS_DIR"/config/hammerspoon/*.lua; do
    link_file "$lua_file" "$HOME/.hammerspoon/$(basename "$lua_file")"
done

if [ -d "$MACOS_DIR/config/hammerspoon/Spoons" ]; then
    mkdir -p "$HOME/.hammerspoon/Spoons"
    for spoon_dir in "$MACOS_DIR"/config/hammerspoon/Spoons/*.spoon; do
        [ -e "$spoon_dir" ] || continue
        link_path "$spoon_dir" "$HOME/.hammerspoon/Spoons/$(basename "$spoon_dir")"
    done
fi


# --- Remove Quarantine Attribute ---
function remove_quarantine_attribute() {
    echo "Removing quarantine attribute from applications..."
    local apps_file="$MACOS_DIR/packages/apps.txt"
    if [ -f "$apps_file" ]; then
        while IFS= read -r app_name || [[ -n "$app_name" ]]; do
            local app_path="/Applications/${app_name}.app"
            if [ -d "$app_path" ]; then
                sudo xattr -dr com.apple.quarantine "$app_path" 2>/dev/null && echo "Quarantine removed for ${app_name}" || echo "WARN: Failed to remove quarantine for ${app_name} (might be already removed)"
            else
                echo "INFO: Application not found, skipping quarantine removal: ${app_name}"
            fi
        done < "$apps_file"
    else
        echo "WARN: packages/apps.txt not found. Cannot remove quarantine attributes."
    fi
}

if [[ "${REMOVE_QUARANTINE:-0}" == "1" ]]; then
    # Keep-alive: update existing `sudo` time stamp until quarantine cleanup finishes.
    sudo -v
    while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
    remove_quarantine_attribute
else
    echo "Skipping quarantine removal. Set REMOVE_QUARANTINE=1 to run it."
fi


# --- Final Success Message ---
echo ""
echo "=========================================="
echo "    macOS Environment Setup Complete!    "
echo "=========================================="
echo "Next Steps:"
echo "1. Restart your terminal to apply all changes."
echo "2. Open Ghostty, Zed, Hammerspoon, and AeroSpace to complete their initial setup."
echo ""
