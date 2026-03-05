#!/bin/bash
#
# ╔══════════════════════════════════════════════════════════════════════╗
# ║                        macOS Setup Script                          ║
# ╠══════════════════════════════════════════════════════════════════════╣
# ║                                                                    ║
# ║  1. Prerequisites      - Homebrew, mas (auto-installed if missing) ║
# ║  2. Shell Aliases      - term, claude-sudo                         ║
# ║  3. Keyboard Shortcuts - Cmd+Shift+W (New Terminal at Folder)      ║
# ║  4. Terminal Profile   - "bang" profile for Terminal.app            ║
# ║  5. GUI Apps           - Pasta (App Store), Rectangle (Homebrew)   ║
# ║  6. CLI Tools          - claude, claude-irc, vaultkey, xcodegen    ║
# ║                                                                    ║
# ║  All steps are idempotent — safe to run multiple times.            ║
# ║                                                                    ║
# ╚══════════════════════════════════════════════════════════════════════╝
#

set -e

ZSHRC="$HOME/.zshrc"
REPO_RAW="https://raw.githubusercontent.com/bang9/bang-settings/main"

###############################################################################
# 1. Prerequisites                                                            #
#    - Homebrew: package manager (required for GUI/CLI app installs)           #
#    - mas: Mac App Store CLI (required for App Store app installs)            #
###############################################################################
echo "=== 1. Prerequisites ==="

# Homebrew
if command -v brew &>/dev/null; then
  echo "[skip] Homebrew already installed ($(brew --version | head -1))"
else
  echo "[install] Homebrew not found. Installing..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo "[done] Homebrew installed"
fi

# mas (Mac App Store CLI)
if command -v mas &>/dev/null; then
  echo "[skip] mas already installed ($(mas version))"
else
  echo "[install] mas not found. Installing via Homebrew..."
  brew install mas
  echo "[done] mas installed"
fi

###############################################################################
# 2. Shell Aliases                                                            #
#    - term          : open Terminal.app in current directory                  #
#    - claude-sudo   : run claude with --dangerously-skip-permissions         #
#                                                                             #
#    Check: grep for existing alias definition in .zshrc                      #
#    Install: append alias line to .zshrc                                     #
###############################################################################
echo ""
echo "=== 2. Shell Aliases ==="

add_alias() {
  local name="$1"
  local value="$2"

  # Check: does alias already exist in .zshrc?
  if grep -q "^alias ${name}=" "$ZSHRC" 2>/dev/null; then
    echo "[skip] alias '${name}' — already defined in .zshrc"
  else
    # Install: append to .zshrc
    echo "alias ${name}='${value}'" >> "$ZSHRC"
    echo "[done] alias '${name}=${value}' — added to .zshrc"
  fi
}

add_alias "term" "open -a Terminal ."
add_alias "claude-sudo" "claude --dangerously-skip-permissions"

###############################################################################
# 3. Keyboard Shortcuts                                                       #
#    - Cmd+Shift+W -> "New Terminal at Folder" (Finder service)               #
#                                                                             #
#    Check: read pbs (Pasteboard Server) preferences for key_equivalent       #
#    Install: defaults write to pbs NSServicesStatus                          #
#    Note: requires log out/in or killall Finder to take effect               #
###############################################################################
echo ""
echo "=== 3. Keyboard Shortcuts ==="

SERVICE_KEY="com.apple.Terminal - New Terminal at Folder - newTerminalAtFolder"
CURRENT=$(defaults read pbs NSServicesStatus 2>/dev/null | grep -A2 "$SERVICE_KEY" | grep "key_equivalent" || true)

# Check: is Cmd+Shift+W (@$w) already assigned?
if [[ "$CURRENT" == *'@$w'* ]]; then
  echo "[skip] Cmd+Shift+W -> New Terminal at Folder — already configured"
else
  # Install: write key equivalent to pbs preferences
  defaults write pbs NSServicesStatus -dict-add \
    "\"${SERVICE_KEY}\"" \
    '{ "enabled_context_menu" = 1; "enabled_services_menu" = 1; "key_equivalent" = "@$w"; }'
  echo "[done] Cmd+Shift+W -> New Terminal at Folder"
  echo "       (log out/in or 'killall Finder' to activate)"
fi

###############################################################################
# 4. Terminal Profile                                                         #
#    - Profile name: "bang"                                                   #
#    - Source: bang-shell-profile.terminal from bang-settings repo             #
#                                                                             #
#    Check: defaults read com.apple.Terminal "Default Window Settings"        #
#    Install: download .terminal file, open (imports), set as default         #
###############################################################################
echo ""
echo "=== 4. Terminal Profile ==="

PROFILE_NAME="bang"
CURRENT_DEFAULT=$(defaults read com.apple.Terminal "Default Window Settings" 2>/dev/null || true)

# Check: is "bang" already the default profile?
if [[ "$CURRENT_DEFAULT" == "$PROFILE_NAME" ]]; then
  echo "[skip] Terminal profile '${PROFILE_NAME}' — already set as default"
else
  # Install: download .terminal file and import into Terminal.app
  TMPFILE=$(mktemp /tmp/bang-profile.XXXXXX.terminal)
  curl -fsSL "${REPO_RAW}/bang-shell-profile.terminal" -o "$TMPFILE"
  open "$TMPFILE"
  sleep 1

  # Set as default profile for new windows and startup
  defaults write com.apple.Terminal "Default Window Settings" -string "$PROFILE_NAME"
  defaults write com.apple.Terminal "Startup Window Settings" -string "$PROFILE_NAME"
  rm -f "$TMPFILE"

  echo "[done] Terminal profile '${PROFILE_NAME}' imported and set as default"
fi

###############################################################################
# 5. GUI Apps                                                                 #
#    - Pasta     (App Store ID: 1438389787) — clipboard manager               #
#    - Rectangle (Homebrew Cask: rectangle) — window manager                  #
#                                                                             #
#    Check (App Store): mas list | grep <app_id>                              #
#    Check (Cask): brew list --cask <cask_name>                               #
#    Install: mas install / brew install --cask                               #
###############################################################################
echo ""
echo "=== 5. GUI Apps ==="

# --- Pasta (Mac App Store) ---
PASTA_ID=1438389787
if mas list 2>/dev/null | grep -q "$PASTA_ID"; then
  echo "[skip] Pasta — already installed"
else
  echo "[install] Pasta — installing from App Store (ID: ${PASTA_ID})..."
  mas install "$PASTA_ID"
  echo "[done] Pasta installed"
fi

# --- Rectangle (Homebrew Cask) ---
if brew list --cask rectangle &>/dev/null; then
  echo "[skip] Rectangle — already installed"
else
  echo "[install] Rectangle — installing via Homebrew Cask..."
  brew install --cask rectangle
  echo "[done] Rectangle installed"
fi

###############################################################################
# 6. CLI Tools                                                                #
#    - claude     : Claude Code CLI                                           #
#    - claude-irc : inter-session communication for Claude Code agents        #
#    - vaultkey   : encrypted secrets manager                                 #
#    - xcodegen   : generate Xcode projects from YAML spec                    #
#                                                                             #
#    Check: command -v <tool_name>                                            #
#    Install: curl / brew                                                     #
###############################################################################
echo ""
echo "=== 6. CLI Tools ==="

# --- claude (Claude Code CLI) ---
if command -v claude &>/dev/null; then
  echo "[skip] claude — already installed"
else
  echo "[install] claude — installing Claude Code CLI..."
  curl -fsSL https://claude.ai/install.sh | bash
  echo "[done] claude installed"
fi

# --- claude-irc ---
if command -v claude-irc &>/dev/null; then
  echo "[skip] claude-irc — already installed"
else
  echo "[install] claude-irc — installing..."
  curl -fsSL https://raw.githubusercontent.com/bang9/ai-tools/main/claude-irc/install.sh | bash
  echo "[done] claude-irc installed"
fi

# --- vaultkey ---
if command -v vaultkey &>/dev/null; then
  echo "[skip] vaultkey — already installed"
else
  echo "[install] vaultkey — installing..."
  curl -fsSL https://raw.githubusercontent.com/bang9/ai-tools/main/vaultkey/install.sh | bash
  echo "[done] vaultkey installed"
fi

# --- xcodegen (Xcode project generator) ---
if command -v xcodegen &>/dev/null; then
  echo "[skip] xcodegen — already installed"
else
  echo "[install] xcodegen — installing via Homebrew..."
  brew install xcodegen
  echo "[done] xcodegen installed"
fi

###############################################################################
# Done                                                                        #
###############################################################################
echo ""
echo "============================================"
echo "  Setup complete!"
echo "============================================"
echo ""
echo "Next steps:"
echo "  - Run 'source ~/.zshrc' to apply aliases in current shell"
echo "  - Log out/in if keyboard shortcut was newly configured"
