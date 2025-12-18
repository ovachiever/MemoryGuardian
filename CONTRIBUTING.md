# Contributing to Memory Guardian

Thanks for your interest in contributing! 🎉

## Ways to Contribute

- 🐛 Report bugs
- 💡 Suggest features
- 📝 Improve documentation
- 🔧 Submit pull requests

## Development Setup

1. Fork and clone the repo
2. Make changes to `plugins/memory.30s.sh`
3. Test by copying to your SwiftBar plugins folder:
   ```bash
   cp plugins/memory.30s.sh ~/Library/Application\ Support/SwiftBar/Plugins/
   ```
4. Click the SwiftBar icon → Refresh All

## Pull Request Process

1. Create a feature branch (`git checkout -b feature/amazing-feature`)
2. Make your changes
3. Test thoroughly
4. Commit with clear messages
5. Push and open a PR

## Code Style

- Use shellcheck to lint bash scripts
- Add comments for complex logic
- Keep the plugin lightweight (runs every 30s)

## Reporting Bugs

Include:
- macOS version
- Mac model (Intel/Apple Silicon)
- RAM amount
- Steps to reproduce
- Expected vs actual behavior

## Feature Requests

Open an issue describing:
- The problem you're trying to solve
- Your proposed solution
- Any alternatives you considered

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
