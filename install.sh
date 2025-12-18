#!/bin/bash

# Memory Guardian Installer
# https://github.com/YOUR_USERNAME/MemoryGuardian

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SWIFTBAR_URL="https://github.com/swiftbar/SwiftBar/releases/latest/download/SwiftBar.zip"

echo ""
echo "🧠 Memory Guardian Installer"
echo "============================"
echo ""

# Check macOS version
if [[ $(uname) != "Darwin" ]]; then
    echo "❌ This tool only works on macOS"
    exit 1
fi

# Install SwiftBar if not present
if [ ! -d "/Applications/SwiftBar.app" ]; then
    echo "📦 SwiftBar not found. Installing..."
    
    # Try Homebrew first
    if command -v brew &>/dev/null; then
        echo "   Using Homebrew..."
        brew install --cask swiftbar
    else
        # Download directly
        echo "   Downloading from GitHub..."
        TEMP_DIR=$(mktemp -d)
        curl -sL "$SWIFTBAR_URL" -o "$TEMP_DIR/SwiftBar.zip"
        unzip -q "$TEMP_DIR/SwiftBar.zip" -d "$TEMP_DIR"
        mv "$TEMP_DIR/SwiftBar.app" /Applications/
        rm -rf "$TEMP_DIR"
    fi
    echo "✓ SwiftBar installed"
else
    echo "✓ SwiftBar already installed"
fi

# Create plugins directory
PLUGIN_DIR="$HOME/Library/Application Support/SwiftBar/Plugins"
mkdir -p "$PLUGIN_DIR"
echo "✓ Plugin directory ready"

# Copy plugin
cp "$SCRIPT_DIR/plugins/memory.30s.sh" "$PLUGIN_DIR/"
chmod +x "$PLUGIN_DIR/memory.30s.sh"
echo "✓ Memory Guardian plugin installed"

# Configure SwiftBar plugin directory
defaults write com.ameba.SwiftBar PluginDirectory -string "$PLUGIN_DIR"
echo "✓ SwiftBar configured"

# Launch SwiftBar
echo ""
echo "🚀 Launching SwiftBar..."
sleep 1
open /Applications/SwiftBar.app

echo ""
echo "============================"
echo "✅ Installation complete!"
echo ""
echo "Look for a colored circle in your menu bar:"
echo "  🟢 = All good"
echo "  🟠 = Elevated - keep an eye on it"
echo "  🟡 = Warning - close some apps soon"
echo "  🔴 = CRITICAL - save your work NOW!"
echo ""
echo "Click the icon to see memory details."
echo ""
echo "Tip: Enable 'Launch at Login' in SwiftBar preferences"
echo "     (Click icon → Preferences → Launch at Login)"
echo ""
