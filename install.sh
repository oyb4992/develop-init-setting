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
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

echo "INFO: Detected Operating System: $OS"

case "$OS" in
    macos|linux)
        ;;
    windows)
        echo "INFO: Windows setup is not automated yet."
        echo "INFO: Apply files under '$SCRIPT_DIR/os/windows/' manually for now."
        exit 0
        ;;
    *)
        echo "ERROR: Unsupported operating system." >&2
        exit 1
        ;;
esac

# --- Execute Common Installation ---
if [ -f "$SCRIPT_DIR/os/common/install.sh" ]; then
    echo "INFO: Running common setup script..."
    bash "$SCRIPT_DIR/os/common/install.sh"
else
    echo "WARN: Common setup script not found, skipping."
fi

# --- Execute OS-specific Installation ---
case "$OS" in
    macos)
        if [ -f "$SCRIPT_DIR/os/macos/install.sh" ]; then
            echo "INFO: Running macOS setup script..."
            bash "$SCRIPT_DIR/os/macos/install.sh"
        else
            echo "ERROR: macOS setup script not found." >&2
            exit 1
        fi
        ;;
    linux)
        echo "INFO: Linux setup not yet implemented."
        # if [ -f "$SCRIPT_DIR/os/linux/install.sh" ]; then
        #     bash "$SCRIPT_DIR/os/linux/install.sh"
        # fi
        ;;
esac

echo "INFO: Setup process finished."
