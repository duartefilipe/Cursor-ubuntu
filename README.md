

---
## 🚀 Quick Start (One-Line Installation)

Run this command to install/update Cursor directly without cloning the repository:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/hieutt192/Cursor-ubuntu/refs/heads/main/manage_cursor.sh)"
```

> **Note:** For Ubuntu 24.04 installation, please switch to the `Cursor-ubuntu24.04` branch or visit: [Link](https://github.com/hieutt192/Cursor-ubuntu/tree/Cursor-ubuntu24.04)

---

## 🎨 Script Interface

When you run the script, you'll see a user-friendly menu interface:

```
   ______                              ___    ____   ________  ______
  / ____/_  ________________  _____   /   |  /  _/  /  _/ __ \/ ____/
 / /   / / / / ___/ ___/ __ \/ ___/  / /| |  / /    / // / / / __/   
/ /___/ /_/ / /  (__  ) /_/ / /     / ___ |_/ /   _/ // /_/ / /___   
\____/\__,_/_/  /____/\____/_/     /_/  |_/___/  /___/_____/_____/   
                                                                     
For Ubuntu 22.04
-------------------------------------------------
  /\_/\
 ( o.o )
  > ^ <
------------------------
1. 💿 Install Cursor
2. 🆙 Update Cursor
3. 🗑️ Uninstall Cursor
Note: If the menu reappears after choosing an option, check any error message above.
------------------------
Please choose an option (1, 2, or 3): 
```

This is a guideline and script for installing or updating Cursor on Ubuntu 22.04.

## ✨ Features
- 🚀 **One-line Installation:** Install directly from GitHub without cloning
- 📦 **Auto-download:** Automatically fetches latest Cursor AppImage 
- 🔄 **Easy Update:** Update to newest version with single command
- 🗑️ **Complete Uninstall:** Remove Cursor and all related files
- 🎨 **Icon Selection:** Choose your preferred application icon
- 🖥️ **Desktop Integration:** Automatic menu entry creation

## ⚙️ Prerequisites
- 🐧 Ubuntu 22.04 or compatible Linux distribution
- 🌐 Internet connection
- 🔑 `sudo` privileges
- 📦 `curl` (auto-installed if missing)
- 📦 `libfuse2` (auto-installed if missing)

---

## 🎨 Available Icons
- <img src="images/cursor-icon.png" alt="Cursor Icon" width="24"/> `cursor-icon.png` – Standard Cursor logo with blue background  
- <img src="images/cursor-black-icon.png" alt="Cursor Black Icon" width="24"/> `cursor-black-icon.png` – Cursor logo with dark background

---

## ⚠️ Important Notes
- **Ubuntu 22.04:** The script automatically installs `libfuse2` for AppImage support
- **Ubuntu 24.04+:** Do NOT install `libfuse2` manually - it can cause graphical issues
- **Restart recommended:** For best experience, restart after installation
- **Sudo required:** Script needs admin privileges for system-wide installation

---

## 🧩 Troubleshooting
If you encounter any issues:
1. **Permission errors:** Ensure you have `sudo` privileges and active internet connection
2. **Script fails to download:** Check your network connection and try again
3. **Cursor won't start:** The script handles `libfuse2` automatically, but you can verify with:
   ```bash
   sudo apt update && sudo apt install libfuse2
   ```
4. **Desktop entry missing:** Log out and log back in, or restart your computer

---

## 📝 Version History

### 2.3 (Current) 
**Optimized Script Interface and Enhanced User Experience:**
- **One-line Installation:** Direct installation via curl command
- **Uninstall Option:** Complete removal functionality in main menu
- **Enhanced UI:** Improved menu design with emojis and better alignment
- **Smart Auto-download:** Intelligent download with automatic fallback
- **Simplified Desktop Integration:** Clear guidance for icon refresh without automatic commands

### 2.2 
**Terminal Display Enhancement:** Added figlet library for ASCII art banners and improved visual experience

### 2.1 
**Ubuntu Compatibility:** Added version checking and automatic libfuse2 installation for Ubuntu 22.04

### 2.0 
**Auto-download System:** Implemented automatic Cursor AppImage fetching with manual fallback option

### 1.0 
**Initial Release:** Basic installation and update functionality with manual AppImage path
