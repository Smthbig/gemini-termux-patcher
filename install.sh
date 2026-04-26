#!/data/data/com.termux/files/usr/bin/bash

# install.sh - One-click installer for Gemini CLI on Termux
# This script prepares Termux, clones the official repo, and applies patches.

set -e

echo "🚀 Starting Gemini CLI Full Environment Setup for Termux..."

# 1. Termux Environment Setup
echo "📱 Setting up Termux environment..."
if [ ! -d "$HOME/storage" ]; then
    echo "  - Requesting storage access (please click 'Allow' on the popup)..."
    termux-setup-storage
fi

# Ensure basic utilities are present
echo "📦 Updating packages and installing dependencies..."
pkg update -y && pkg upgrade -y
pkg install -y nodejs python clang make binutils pkg-config libuv git termux-api

# 2. Configure Shell for Optimal Gemini Experience
echo "🐚 Optimizing shell configuration..."
# Set TERM to xterm-256color if not already set in .bashrc or .zshrc
SHELL_CONFIG="$HOME/.bashrc"
[ -n "$ZSH_VERSION" ] && SHELL_CONFIG="$HOME/.zshrc"

if ! grep -q "TERM=xterm-256color" "$SHELL_CONFIG" 2>/dev/null; then
    echo 'export TERM=xterm-256color' >> "$SHELL_CONFIG"
    echo "  - Added TERM=xterm-256color to $SHELL_CONFIG"
fi

# 3. Clone the Original Repository
REPO_DIR="gemini-cli-source"
if [ -d "$REPO_DIR" ]; then
    echo "  - folder $REPO_DIR already exists. Updating..."
    cd "$REPO_DIR" && git pull && cd ..
else
    echo "  - git cloning original gemini-cli..."
    git clone https://github.com/google-gemini/gemini-cli.git "$REPO_DIR"
fi

# 4. Apply Termux Patches
echo "🛠️ Applying Termux-specific patches..."
bash ./apply-patches.sh "$REPO_DIR"

# 5. Build the Project
echo "🏗️ Building Gemini CLI (this may take a few minutes)..."
cd "$REPO_DIR"
npm install --omit=dev || npm install # Try with omit first, fallback to full if needed
if grep -q "\"build\":" package.json; then
    npm run build
fi

# 6. Create Global Command
echo "🔗 Creating 'gemini' global command..."
# We use the built js if it exists, otherwise the entry ts
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
echo "✅ Installation & Setup Complete!"
echo "🎉 You can now run 'gemini' from your terminal."
echo "--------------------------------------------------"
echo "💡 IMPORTANT: To use Gemini, you need an API Key."
echo "   1. Get one at: https://aistudio.google.com/app/apikey"
echo "   2. Add it to your shell config:"
echo "      echo 'export GEMINI_API_KEY=your_key_here' >> $SHELL_CONFIG"
echo "   3. Restart Termux or run: source $SHELL_CONFIG"
echo "--------------------------------------------------"
