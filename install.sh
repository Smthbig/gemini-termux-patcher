#!/data/data/com.termux/files/usr/bin/bash

# install.sh - One-click installer for Gemini CLI on Termux
# This script prepares Termux, clones the official repo, and applies patches.

set -e

echo "🚀 Starting Gemini CLI Unified Workstation Setup for Termux..."

# 1. Termux Environment & Interface Optimization
echo "📱 Optimizing Termux interface & visuals..."
if [ ! -d "$HOME/storage" ]; then
    echo "  - Requesting storage access..."
    termux-setup-storage
fi

# Visuals & Power-User Keyboard
mkdir -p ~/.termux
cat <<EOF > ~/.termux/termux.properties
terminal-cursor-blink-rate = 400
terminal-cursor-style = block
extra-keys = [['ESC','/','-','HOME','UP','END','PGUP'], \\
              ['TAB','CTRL','ALT','LEFT','DOWN','RIGHT','PGDN']]
EOF
termux-reload-settings

# 2. Package & Toolchain Installation
echo "📦 Installing high-performance toolchain..."
pkg update -y && pkg upgrade -y
pkg install -y nodejs python clang make binutils pkg-config libuv git termux-api \
               ripgrep fd jq bat fzf bash-completion openssh man fontconfig-utils

# 3. Git & IO Acceleration
echo "🏎️ Accelerating Git and IO performance..."
git config --global core.preloadIndex true
git config --global core.fscache true
git config --global gc.auto 256
git config --global core.quotepath false
git config --global help.autocorrect 1

# 4. Shell Optimization (~/.bashrc)
echo "🐚 Configuring Git-aware prompt and productivity aliases..."
SHELL_CONFIG="$HOME/.bashrc"
[ -n "$ZSH_VERSION" ] && SHELL_CONFIG="$HOME/.zshrc"

# Create a optimized .bashrc snippet
cat <<'EOF' > ~/.bashrc_gemini
# Performance
export NODE_OPTIONS="--max-old-space-size=2048"
export PAGER="bat"
export EDITOR="nano"
export LANG="en_US.UTF-8"

# FZF & Completion
[ -f /data/data/com.termux/files/usr/share/bash-completion/bash_completion ] && . /data/data/com.termux/files/usr/share/bash-completion/bash_completion
command -v fzf >/dev/null 2>&1 && source <(fzf --bash)

# Optimized Prompt
PS1='\[\033[01;32m\]\w\[\033[00m\]$(__git_ps1 " (\[\033[01;33m\]%s\[\033[00m\])") \[\033[01;34m\]◇\[\033[00m\] '

# Aliases: Gemini
alias ai="gemini"
alias g="gemini"
alias g-res="gemini --resume"
alias g-list="gemini --list-sessions"

# Aliases: Productivity
alias work="cd /storage/emulated/0/CodeOnTheGoProjects"
alias ls="ls --color=auto"
alias ll="ls -lah --color=auto"
alias grep="grep --color=auto"
alias ..="cd .."
alias h="history"
alias c="clear"

# Termux AI Bridge
alias clip="termux-clipboard-get"
alias setclip="termux-clipboard-set"
alias notify="termux-notification -t"
EOF

if ! grep -q "source ~/.bashrc_gemini" "$SHELL_CONFIG"; then
    echo "source ~/.bashrc_gemini" >> "$SHELL_CONFIG"
fi

# 5. Gemini CLI Configuration (~/.gemini/)
echo "⚙️ Configuring Gemini CLI for mobile efficiency..."
mkdir -p ~/.gemini
cat <<EOF > ~/.gemini/settings.json
{
  "ui": {
    "inlineThinkingMode": "off",
    "hideBanners": true,
    "hideTips": true,
    "hideFooterLabels": true
  },
  "general": {
    "defaultApprovalMode": "auto_edit"
  }
}
EOF

cat <<'EOF' > ~/.gemini/GEMINI.md
# Global Termux Optimizations

## Environment Awareness:
- Operating in **Termux on Android**. Screen space is limited.
- **Conciseness is mandatory**: Avoid verbose explanations. Use short, direct sentences.
- **Code First**: When asked for code, provide it immediately without excessive preamble.

## Tool Preferences:
- **Paging**: Always assume `bat` is available for viewing files with syntax highlighting.
- **Searching**: Use `ripgrep` (`rg`) or `fd` for fast filesystem operations.
- **Editor**: Default to `nano`.
- **JSON**: Use `jq` for any JSON processing tasks in the shell.

## Performance:
- Be mindful of mobile CPU/Battery. Prefer single-pass shell commands over complex loops.
EOF

# 6. Clone & Patch Process
REPO_DIR="gemini-cli-source"
if [ -d "$REPO_DIR" ]; then
    echo "  - folder $REPO_DIR already exists. Updating..."
    cd "$REPO_DIR" && git pull && cd ..
else
    echo "  - git cloning original gemini-cli..."
    git clone https://github.com/google-gemini/gemini-cli.git "$REPO_DIR"
fi

echo "🛠️ Applying Termux-specific patches..."
bash ./apply-patches.sh "$REPO_DIR"

# 7. Build
echo "🏗️ Building Gemini CLI (this may take a few minutes)..."
cd "$REPO_DIR"
npm install --omit=dev || npm install
[ -f "package.json" ] && grep -q "\"build\":" package.json && npm run build

# 8. Create Global Command
echo "🔗 Creating 'gemini' global command..."
GEMINI_BIN="$(pwd)/packages/cli/index.ts" 
if [ -f "packages/cli/dist/index.js" ]; then
    GEMINI_BIN="$(pwd)/packages/cli/dist/index.js"
fi

cat <<EOF > $PREFIX/bin/gemini
#!/data/data/com.termux/files/usr/bin/bash
# Gemini CLI Termux Wrapper
export GEMINI_CLI=1
node "$GEMINI_BIN" "\$@"
EOF
chmod +x $PREFIX/bin/gemini

echo "--------------------------------------------------"
echo "✅ WORKSTATION SETUP COMPLETE!"
echo "🎉 You now have a high-performance Gemini CLI environment."
echo "--------------------------------------------------"
echo "💡 To activate shell changes, run: source $SHELL_CONFIG"
echo "--------------------------------------------------"
