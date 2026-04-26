# Gemini CLI Termux Patcher

This repository provides a one-click solution to install and optimize the official [Google Gemini CLI](https://github.com/google-gemini/gemini-cli) for the Termux environment on Android.

## 🚀 One-Click Installation

Run the following command in your Termux terminal:

```bash
# Clone this patcher
git clone https://github.com/YOUR_USERNAME/gemini-termux-patcher.git
cd gemini-termux-patcher

# Run the installer
chmod +x install.sh
./install.sh
```

## 🛠️ What this patcher does:

1.  **Environment Preparation**: Updates Termux packages and installs all required build tools (`nodejs`, `python`, `clang`, `make`, etc.).
2.  **Source Patching**:
    *   **Browser Support**: Fixes `openBrowserSecurely` to use `termux-open` for authentication.
    *   **Shell Optimization**: Configures the CLI to use Termux's native `sh` instead of assuming `/bin/bash`.
    *   **System Paths**: Re-routes system settings to Termux-compatible paths (`/usr/etc/gemini-cli`).
    *   **PTY Fix**: Ensures `node-pty` is built from source for your specific Android architecture, avoiding "missing binary" errors.
3.  **Global Installation**: Creates a `gemini` command in your PATH for easy access.

## 📝 Usage

After installation, simply run:
```bash
gemini
```

## 🤝 Contribution

If you find any more parts of Gemini CLI that need optimization for Termux, please open an issue or submit a pull request with a new patch logic in `apply-patches.sh`.

## Credits
Official Gemini CLI by Google. Termux patches maintained by the community.
