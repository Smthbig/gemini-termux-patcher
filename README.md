# Gemini CLI Termux Patcher

This repository provides a unified, high-performance solution to transform Termux into a mobile development workstation optimized for the official [Google Gemini CLI](https://github.com/google-gemini/gemini-cli).

## 🚀 One-Click Workstation Setup

Run the following command in your Termux terminal:

```bash
# Clone this patcher
git clone https://github.com/Smthbig/gemini-termux-patcher.git
cd gemini-termux-patcher

# Run the installer
chmod +x install.sh
./install.sh
```

## 🛠️ Integrated Optimizations:

1.  **Interface & UX**:
    *   **Power-User Keyboard**: Enabled a two-row extra key layout (ESC, TAB, CTRL, ALT, Arrows).
    *   **Visual Polish**: Blinking block cursor for better mobile visibility.
    *   **Smart Prompt**: Fast, Git-aware PS1 showing branch and repo status.
2.  **Performance**:
    *   **Memory Boost**: Increased Node.js heap limit for processing large codebases.
    *   **Git Acceleration**: Optimized Git configuration for Android's filesystem.
    *   **Housekeeping**: Automated repository maintenance.
3.  **Source Patching**:
    *   **Full Android Support**: Patch for `openBrowserSecurely` and `termux-open` integration.
    *   **System Paths**: Correct routing for `/usr/etc/gemini-cli`.
    *   **Native PTY**: Source-built `node-pty` for any Android architecture.
4.  **Integrated Toolchain**:
    *   Installs and integrates: `ripgrep`, `fd`, `jq`, `bat`, `fzf`.
    *   **Termux-AI Bridge**: Hardware-linked aliases (`clip`, `setclip`, `notify`).

## 📝 Usage

After installation, simply run:
```bash
gemini
# OR use shorthands
g
ai
```

## 🤝 Contribution

If you find any more parts of Gemini CLI that need optimization for Termux, please open an issue or submit a pull request with a new patch logic in `apply-patches.sh`.

## Credits
Official Gemini CLI by Google. Termux workstation patches maintained by the community.

