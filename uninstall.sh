#!/bin/bash

# Memory Guardian Uninstaller

echo ""
echo "🧠 Memory Guardian Uninstaller"
echo "=============================="
echo ""

PLUGIN_PATH="$HOME/Library/Application Support/SwiftBar/Plugins/memory.30s.sh"

if [ -f "$PLUGIN_PATH" ]; then
    rm "$PLUGIN_PATH"
    echo "✓ Removed Memory Guardian plugin"
else
    echo "⚠ Plugin not found (already removed?)"
fi

echo ""
read -p "Remove SwiftBar too? [y/N] " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    if command -v brew &>/dev/null; then
        brew uninstall --cask swiftbar 2>/dev/null || rm -rf /Applications/SwiftBar.app
    else
        rm -rf /Applications/SwiftBar.app
    fi
    echo "✓ SwiftBar removed"
fi

echo ""
echo "✅ Uninstall complete"
echo ""
