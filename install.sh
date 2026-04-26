#!/data/data/com.termux/files/usr/bin/bash

# install.sh - One-click installer for Gemini CLI on Termux
# This script prepares Termux, clones the official repo, and applies patches.

set -e

echo "🚀 Starting Gemini CLI One-Click Installation for Termux..."

# 1. Update and Install System Dependencies
echo "📦 Updating packages and installing dependencies..."
pkg update -y && pkg upgrade -y
pkg install -y nodejs python clang make binutils pkg-config libuv git termux-api

# 2. Clone the Original Repository
REPO_DIR="gemini-cli-source"
if [ -d "$REPO_DIR" ]; then
    echo "folder $REPO_DIR already exists. Updating..."
    cd "$REPO_DIR" && git pull && cd ..
else
    echo "git cloning original gemini-cli..."
    git clone https://github.com/google-gemini/gemini-cli.git "$REPO_DIR"
fi

# 3. Apply Termux Patches
echo "🛠️ Applying Termux-specific patches..."
bash ./apply-patches.sh "$REPO_DIR"

# 4. Build the Project
echo "🏗️ Building Gemini CLI (this may take a few minutes)..."
cd "$REPO_DIR"
npm install
# Note: build command might vary, but usually it's npm run build or similar
if grep -q "\"build\":" package.json; then
    npm run build
fi

# 5. Create Global Command
echo "🔗 Creating 'gemini' global command..."
GEMINI_BIN="$(pwd)/packages/cli/index.ts" # Fallback if build path differs
if [ -f "packages/cli/dist/index.js" ]; then
    GEMINI_BIN="$(pwd)/packages/cli/dist/index.js"
fi

cat <<EOF > $PREFIX/bin/gemini
#!/data/data/com.termux/files/usr/bin/bash
node "$GEMINI_BIN" "\$@"
EOF
chmod +x $PREFIX/bin/gemini

echo "✅ Installation Complete!"
echo "🎉 You can now run 'gemini' from your terminal."
