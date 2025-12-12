

---
## 🚀 Quick Start (One-Line Installation)

Run this command to install/update Cursor directly without cloning the repository:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/duartefilipe/Cursor-ubuntu/refs/heads/main/manage_cursor.sh?v=$(date +%s))"
```

> **Note:** The `?v=$(date +%s)` parameter ensures you always get the latest version, avoiding GitHub cache issues.

---

## 🎨 Script Interface

When you run the script, you'll see a user-friendly menu interface:

```
=== Cursor Manager ===
1. 💿 Install Cursor
2. 🆙 Update Cursor
3. 🗑️  Uninstall Cursor
4. 🚪 Exit
------------------------
Select an option [1-4]: 
```

This is a guideline and script for installing or updating Cursor on **Ubuntu** (22.04/24.04+) and **Elementary OS**.

## ✨ Features
- 🚀 **One-line Installation:** Install directly from GitHub without cloning
- 📦 **Atomic Updates:** Downloads and validates the new version *before* replacing the old one (Safe!)
- ⭐ **OS Support:** Full support for **Ubuntu** and **Elementary OS**
- 🤖 **CLI Mode:** Automate tasks with arguments (see below)
- 🗑️ **Complete Uninstall:** Remove Cursor and all related files
- 🖥️ **Desktop Integration:** Automatic menu entry creation

## ⚙️ Prerequisites
- 🐧 Ubuntu, Elementary OS, or compatible Debian-based distribution
- 🌐 Internet connection
- 🔑 `sudo` privileges
- 📦 `curl`, `wget` (auto-installed if missing)
- 📦 `libfuse2` (auto-installed if missing, critical for AppImages)

---

## 🤖 Command Line Arguments (CLI)

You can run the script non-interactively, perfect for automation or quick updates:

```bash
# Install Cursor
sudo ./manage_cursor.sh --install

# Update Cursor
sudo ./manage_cursor.sh --update

# Uninstall Cursor
sudo ./manage_cursor.sh --uninstall
```

---

## ⚠️ Important Notes
- **Dependencies:** The script automatically handles `apt-get update` and installs `libfuse2` if needed.
- **Safety:** Updates are atomic. If the download fails, your existing Cursor installation remains untouched.

---

## 📝 Version History

### 2.4 (Current)
**Robustness & Elementary OS Support:**
- **Atomic Updates:** Safer update process, downloads to temp first.
- **Elementary OS:** Official support added.
- **CLI Arguments:** Added `--install`, `--update`, `--uninstall` flags.
- **Dependency Fixes:** Smarter `apt-get` handling.

### 2.3
**Optimized Script Interface:**
- One-line Installation
- Uninstall Option
- Enhanced User Experience

### 2.0 - 2.2
**Foundations:**
- Auto-download system
- Ubuntu 22.04 compatibility

