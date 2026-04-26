#!/data/data/com.termux/files/usr/bin/bash

# apply-patches.sh - Programmatic patching for Gemini CLI
# Usage: ./apply-patches.sh <target-repo-directory>

set -e

TARGET_DIR=$1

if [ -z "$TARGET_DIR" ] || [ ! -d "$TARGET_DIR" ]; then
    echo "Error: Please provide a valid target directory."
    exit 1
fi

echo "🔧 Patching source code in $TARGET_DIR..."

# Define paths relative to target
BROWSER_LAUNCHER="$TARGET_DIR/packages/core/src/utils/secure-browser-launcher.ts"
SHELL_UTILS="$TARGET_DIR/packages/core/src/utils/shell-utils.ts"
SETTINGS_TS="$TARGET_DIR/packages/cli/src/config/settings.ts"
STORAGE_TS="$TARGET_DIR/packages/core/src/config/storage.ts"
GET_PTY_TS="$TARGET_DIR/packages/core/src/utils/getPty.ts"
PATHS_TS="$TARGET_DIR/packages/core/src/utils/paths.ts"
SANDBOX_FACTORY_TS="$TARGET_DIR/packages/core/src/services/sandboxManagerFactory.ts"

echo "🔧 Patching source code in $TARGET_DIR..."

# 1. Patch secure-browser-launcher.ts
if [ -f "$BROWSER_LAUNCHER" ]; then
    echo "  - Patching Browser Launcher..."
    if ! grep -q "'android':" "$BROWSER_LAUNCHER"; then
        sed -i "/case 'linux':/i \    case 'android':" "$BROWSER_LAUNCHER"
    fi
    sed -i "s/if (platform() === 'linux') {/if (platform() === 'linux' || platform() === 'android') {/" "$BROWSER_LAUNCHER"
fi

# 2. Patch shell-utils.ts
if [ -f "$SHELL_UTILS" ]; then
    echo "  - Patching Shell Utils..."
    sed -i "s/executable: 'bash'/executable: process.env['TERMUX_VERSION'] ? 'sh' : 'bash'/" "$SHELL_UTILS"
fi

# 3. Patch System Paths
if [ -f "$SETTINGS_TS" ]; then
    echo "  - Patching Settings Paths..."
    if ! grep -q "platform() === 'android'" "$SETTINGS_TS"; then
        sed -i "/platform() === 'win32') {/a \  } else if (platform() === 'android') {\n    return '/data/data/com.termux/files/usr/etc/gemini-cli/settings.json';" "$SETTINGS_TS"
    fi
fi

if [ -f "$STORAGE_TS" ]; then
    echo "  - Patching Storage Paths..."
    if ! grep -q "os.platform() === 'android'" "$STORAGE_TS"; then
        sed -i "/os.platform() === 'win32') {/a \    } else if (os.platform() === 'android') {\n      return '/data/data/com.termux/files/usr/etc/gemini-cli';" "$STORAGE_TS"
    fi
fi

# 4. Patch Path Normalization for Android Case-Insensitivity (SDCard)
if [ -f "$PATHS_TS" ]; then
    echo "  - Patching Path Normalization..."
    if ! grep -q "platform === 'android'" "$PATHS_TS"; then
        sed -i "s/const isCaseInsensitive = platform === 'win32' || platform === 'darwin';/const isCaseInsensitive = platform === 'win32' || platform === 'darwin' || platform === 'android';/" "$PATHS_TS"
    fi
fi

# 5. Patch PTY Loader
if [ -f "$GET_PTY_TS" ]; then
    echo "  - Patching PTY Loader..."
    if ! grep -q "isTermux" "$GET_PTY_TS"; then
        sed -i "/export const getPty = async (): Promise<PtyImplementation> => {/a \  const isTermux = !!process.env['TERMUX_VERSION'];\n  if (isTermux) {\n    try {\n      const nodePty = 'node-pty';\n      const module = await import(nodePty);\n      return { module, name: 'node-pty' };\n    } catch {}\n  }" "$GET_PTY_TS"
    fi
fi

# 6. Force Disable Sandbox on Android (unless specifically re-enabled)
if [ -f "$SANDBOX_FACTORY_TS" ]; then
    echo "  - Patching Sandbox Factory..."
    if ! grep -q "platform() === 'android'" "$SANDBOX_FACTORY_TS"; then
         sed -i "/if (sandbox?.enabled) {/a \    if (os.platform() === 'android') return new NoopSandboxManager(options);" "$SANDBOX_FACTORY_TS"
    fi
fi

echo "✨ All patches applied successfully."
