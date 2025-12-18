# 🧠 Memory Guardian

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![macOS](https://img.shields.io/badge/macOS-12%2B-blue)](https://www.apple.com/macos)
[![SwiftBar](https://img.shields.io/badge/SwiftBar-Plugin-orange)](https://github.com/swiftbar/SwiftBar)

A menu bar tool that warns you before your Mac crashes from memory exhaustion.

![Memory Guardian Screenshot](assets/screenshot.png)

## The Problem

Macs can hit memory limits during heavy workloads — AI coding sessions, Electron apps (Slack, VS Code, Cursor, Spotify), browser tabs. When this happens:

1. System creates dozens of swap files
2. Memory compressor hits 100% capacity  
3. Kernel panics with watchdog timeout
4. **You lose all unsaved work**

This is especially common on Apple Silicon Macs running memory-intensive AI/ML workflows.

## The Solution

Memory Guardian sits in your menu bar and shows memory status at a glance:

| Icon | Status | Meaning |
|------|--------|---------|
| 🟢 | OK | All good |
| 🟠 | Elevated | Keep an eye on it |
| 🟡 | Warning | Consider closing some apps |
| 🔴 | Critical | **Save your work NOW** |

Click the icon to see:
- Memory breakdown (Active, Wired, Compressed, Free)
- Swap file count  
- Top memory-consuming apps (color-coded by usage)
- Quick actions (Activity Monitor, purge memory)

When memory hits critical levels, you get an **audible alert** so you can save your work before it's too late.

## Installation

### Quick Install (recommended)

```bash
git clone https://github.com/YOUR_USERNAME/MemoryGuardian.git
cd MemoryGuardian
./install.sh
```

### Manual Install

1. Install [SwiftBar](https://github.com/swiftbar/SwiftBar)
2. Copy `plugins/memory.30s.sh` to your SwiftBar plugins folder
3. Make it executable: `chmod +x memory.30s.sh`

## Configuration

Edit the thresholds at the top of `plugins/memory.30s.sh`:

```bash
SWAP_WARNING=5          # Warn at 5+ swap files
SWAP_CRITICAL=15        # Critical at 15+ swap files  
COMPRESSED_WARNING=70   # Warn at 70% compressed memory
COMPRESSED_CRITICAL=85  # Critical at 85% compressed memory
```

## How It Works

The plugin runs every 30 seconds and checks:

1. **Swap file count** (`/private/var/vm/swapfile*`)
   - Normal: 0-4 files
   - Warning: 5-14 files
   - Critical: 15+ files

2. **Memory compressor usage** (via `vm_stat`)
   - Percentage of RAM occupied by compressed pages
   - When this maxes out, kernel panic is imminent

## Alert Thresholds

| Condition | Warning | Critical |
|-----------|---------|----------|
| Swap files | ≥5 | ≥15 |
| Compressed memory | ≥70% | ≥85% |

## Requirements

- macOS 12 (Monterey) or later
- Apple Silicon or Intel Mac

## Uninstall

```bash
./uninstall.sh
```

Or manually:
```bash
rm ~/Library/Application\ Support/SwiftBar/Plugins/memory.30s.sh
# Optionally remove SwiftBar
brew uninstall --cask swiftbar
```

## Contributing

Contributions welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) first.

## License

MIT — see [LICENSE](LICENSE)

## Credits

- Built with [SwiftBar](https://github.com/swiftbar/SwiftBar)
- Inspired by losing too much work to kernel panics 😅

## Related

- [SwiftBar Plugins](https://github.com/swiftbar/swiftbar-plugins) — More menu bar plugins
- [Stats](https://github.com/exelban/stats) — Full system monitor for macOS
