# bang-settings

Personal macOS settings and setup automation.

## Quick Setup

```bash
curl -fsSL https://raw.githubusercontent.com/bang9/bang-settings/main/setup-mac.sh | bash
```

## What it does

| Step | Description |
|------|-------------|
| 1. Prerequisites | Homebrew, mas (auto-installed if missing) |
| 2. Shell Aliases | `term` (open Terminal here), `claude-sudo` (skip permissions) |
| 3. Keyboard Shortcuts | `Cmd+Shift+W` → New Terminal at Folder |
| 4. Terminal Profile | Import and apply `bang` profile |
| 5. GUI Apps | Pasta (clipboard manager), Rectangle (window manager) |
| 6. CLI Tools | claude, claude-irc, vaultkey |

All steps are idempotent — safe to run multiple times.

## Shell Profile

<img src="./screenshot.png" width=60% />

## Files

- `setup-mac.sh` — automated setup script
- `bang-shell-profile.terminal` — Terminal.app profile
- `webstorm-settings.zip` — WebStorm IDE settings
