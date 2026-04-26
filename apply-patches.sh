#!/data/data/com.termux/files/usr/bin/bash

# apply-patches.sh - Programmatic patching for Gemini CLI
# Usage: ./apply-patches.sh <target-repo-directory>

set -e

TARGET_DIR=$1
PATCHES_DIR="$(pwd)/patches"

if [ -z "$TARGET_DIR" ] || [ ! -d "$TARGET_DIR" ]; then
    echo "Error: Please provide a valid target directory."
    exit 1
fi

echo "🔧 Applying managed patches from $PATCHES_DIR..."
cd "$TARGET_DIR"
# Sort patches numerically to ensure correct order
for patch in $(ls "$PATCHES_DIR"/*.patch | sort); do
    if [ -f "$patch" ]; then
        echo "  - Applying $(basename "$patch")..."
        git apply "$patch" || echo "    ⚠️ Warning: Failed to apply $(basename "$patch"), it might be already applied or have conflicts."
    fi
done

echo "🔧 Running additional programmatic optimizations..."

# 1. Patch all shebangs to Termux paths
echo "  - Fixing shebangs..."
grep -rl "#!/usr/bin/env" . | xargs sed -i "s|#!/usr/bin/env|#!/data/data/com.termux/files/usr/bin/env|g"

# 2. Patch generic Linux checks to include Android (if not already handled by patches)
echo "  - Expanding generic Linux checks to support Android..."
grep -rl "=== 'linux'" packages | while read -r file; do
    if [[ "$file" != *".test."* && "$file" != *".d.ts" ]]; then
        sed -i "s/=== 'linux'/=== 'linux' || platform() === 'android'/g" "$file"
        sed -i "s/process.platform === 'linux'/process.platform === 'linux' || process.platform === 'android'/g" "$file"
    fi
done

# 3. Ensure local execution of native binaries (disable sandbox by default)
SANDBOX_FACTORY_TS="packages/core/src/services/sandboxManagerFactory.ts"
if [ -f "$SANDBOX_FACTORY_TS" ]; then
    if ! grep -q "os.platform() === 'android'" "$SANDBOX_FACTORY_TS"; then
         echo "  - Patching Sandbox Factory for Android..."
         sed -i "/if (sandbox?.enabled) {/a \    if (os.platform() === 'android') return new NoopSandboxManager(options);" "$SANDBOX_FACTORY_TS"
    fi
fi

echo "✨ All patches and optimizations applied successfully."
