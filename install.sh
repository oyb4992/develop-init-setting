#!/bin/bash
set -euo pipefail

# Function to detect the operating system
detect_os() {
    case "$(uname -s)" in
        Darwin)
            echo "macos"
            ;;
        Linux)
            echo "linux"
            ;;
        CYGWIN*|MINGW*|MSYS*)
            echo "windows"
            ;;
        *)
            echo "unsupported"
            ;;
    esac
}

OS=$(detect_os)

echo "INFO: Detected Operating System: $OS"

# --- Execute Common Installation ---
if [ -f "os/common/install.sh" ]; then
    echo "INFO: Running common setup script..."
    bash "os/common/install.sh"
else
    echo "WARN: Common setup script not found, skipping."
fi

# --- Execute OS-specific Installation ---
case "$OS" in
    macos)
        if [ -f "os/macos/install.sh" ]; then
            echo "INFO: Running macOS setup script..."
            bash "os/macos/install.sh"
        else
            echo "ERROR: macOS setup script not found." >&2
            exit 1
        fi
        ;;
    linux)
        echo "INFO: Linux setup not yet implemented."
        # if [ -f "os/linux/install.sh" ]; then
        #     bash "os/linux/install.sh"
        # fi
        ;;
    windows)
        echo "INFO: For Windows, please run the 'os/windows/install.ps1' script in PowerShell."
        ;;
    *)
        echo "ERROR: Unsupported operating system." >&2
        exit 1
        ;;
esac

echo "INFO: Setup process finished."
