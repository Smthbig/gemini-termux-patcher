#!/data/data/com.termux/files/usr/bin/bash
set -e

TARGET_DIR=$1
PATCHES_DIR="$(pwd)/patches"

if [ -z "$TARGET_DIR" ] || [ ! -d "$TARGET_DIR" ]; then
    echo "Error: Invalid target directory."
    exit 1
fi

echo "🔧 Preparing repository..."
cd "$TARGET_DIR"

# Ensure clean repo state
git reset --hard >/dev/null 2>&1 || true
git clean -fd >/dev/null 2>&1 || true

echo "🔧 Applying managed patches from $PATCHES_DIR..."

for patch in $(ls "$PATCHES_DIR"/*.patch 2>/dev/null | sort); do
    echo "  - Applying $(basename "$patch")..."

    if git apply --check "$patch" >/dev/null 2>&1; then
        git apply "$patch"
        echo "    ✓ Applied"
    else
        echo "    ⚠️ Skipped (already applied or incompatible)"
    fi
done

echo "🔧 Running additional optimizations..."

# 1. Fix shebangs safely
echo "  - Fixing shebangs..."
FILES=$(grep -rl "#!/usr/bin/env" . || true)
if [ -n "$FILES" ]; then
    echo "$FILES" | xargs sed -i \
    "s|#!/usr/bin/env|#!/data/data/com.termux/files/usr/bin/env|g"
fi

# 2. Android platform patch (safe, idempotent)
echo "  - Updating platform checks..."

FILES=$(grep -rl "process.platform === 'linux'" packages 2>/dev/null || true)

for file in $FILES; do
    if ! grep -q "process.platform === 'android'" "$file"; then
        sed -i \
        "s/process.platform === 'linux'/process.platform === 'linux' || process.platform === 'android'/g" \
        "$file"
    fi
done

# 3. Sandbox patch (safe insert)
SANDBOX_FACTORY_TS="packages/core/src/services/sandboxManagerFactory.ts"

if [ -f "$SANDBOX_FACTORY_TS" ]; then
    if ! grep -q "NoopSandboxManager(options);" "$SANDBOX_FACTORY_TS"; then
        echo "  - Patching Sandbox Factory..."

        sed -i "/if (sandbox?.enabled) {/a \\
    if (os.platform() === 'android') return new NoopSandboxManager(options);
" "$SANDBOX_FACTORY_TS"
    fi
fi

echo "✨ Patching complete."