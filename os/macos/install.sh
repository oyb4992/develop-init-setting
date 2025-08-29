#!/bin/bash
set -euo pipefail

echo "--- Starting macOS setup ---"

# Get the absolute path of the script's directory
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
MACOS_DIR=$SCRIPT_DIR
PROJECT_ROOT=$(dirname "$(dirname "$MACOS_DIR")")

# --- Homebrew Installation ---
if ! command -v brew &> /dev/null; then
    echo "Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    if [[ "$(uname -m)" == "arm64" ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
fi

# Keep-alive: update existing `sudo` time stamp until the script has finished
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# --- Brew Bundle Installation ---
echo "Installing packages from Brewfile..."
if [ -f "$MACOS_DIR/packages/Brewfile" ]; then
    brew bundle --file="$MACOS_DIR/packages/Brewfile"
else
    echo "ERROR: Brewfile not found at $MACOS_DIR/packages/Brewfile" >&2
    exit 1
fi

# --- Configure macOS-specific tools ---
function configure_macos_tool() {
    local tool_name=$1
    local install_script_path=$2

    echo "Configuring ${tool_name}..."
    if [ -f "${install_script_path}" ]; then
        chmod +x "${install_script_path}"
        # Pass project root to sub-scripts if they need it
        PROJECT_ROOT="$PROJECT_ROOT" bash "${install_script_path}"
    else
        echo "WARN: Install script not found: ${install_script_path}"
    fi
}

# Configure Karabiner
configure_macos_tool "Karabiner" "$MACOS_DIR/config/karabiner/install.sh"

# Configure iTerm2 (if needed)
# configure_macos_tool "iTerm2" "$MACOS_DIR/config/iterm2/install.sh"


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

remove_quarantine_attribute


# --- Final Success Message ---
echo ""
echo "=========================================="
echo "    macOS Environment Setup Complete!    "
echo "=========================================="
echo "Next Steps:"
echo "1. Restart your terminal to apply all changes."
echo "2. Open Raycast, Karabiner-Elements, etc. to complete their initial setup."
echo ""
