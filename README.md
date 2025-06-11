# Cursor AI IDE Installer for Ubuntu 24.04

This repository provides a simple script to install or update the Cursor AI IDE on Ubuntu 24.04. The script supports both automatic download of the latest AppImage and manual installation from a local file.

---

## 📝 Version History

### 1.0 (Current)
- Initial release for Ubuntu 24.04
- Automatic download of the latest Cursor AppImage from the official website
- Option to specify a local AppImage file path
- Icon selection during installation
- Easy update process with the same options as installation
- Clean user prompts and error handling

---

## Prerequisites
- Ubuntu 24.04 (or compatible)
- Internet connection
- `sudo` privileges
- `curl`, `wget`, and `jq` (the script will attempt to install them if missing)

---

## ✨ Features
- **Automatic Download:** Fetch and install the latest Cursor AppImage with one click.
- **Manual Path Option:** Use a previously downloaded AppImage if you prefer.
- **Icon Selection:** Choose your preferred icon during setup.
- **Easy Update:** Update Cursor to the latest version using the same script.

---

## 🎨 Available Icons
- <img src="images/cursor-icon.png" alt="Cursor Icon" width="24"/> `cursor-icon.png` – Standard Cursor logo with blue background
- <img src="images/cursor-black-icon.png" alt="Cursor Black Icon" width="24"/> `cursor-black-icon.png` – Cursor logo with dark/black background

You will be prompted to choose one of these icons during installation.

---

## 🚀 Installation & Update Steps

1. **Download the Script**
    - Clone this repository or download the `manage_cursor.sh` file.
    - Make the script executable:
      ```zsh
      chmod +x manage_cursor.sh
      ```

2. **Run the Script**
    - Start the script:
      ```zsh
      ./manage_cursor.sh
      ```
    - Follow the menu prompts:
      - Choose '1' to **Install Cursor**
      - Choose '2' to **Update Cursor**
    - You will be asked how to provide the Cursor AppImage:
      - **Option 1 (Recommended):** Auto-download the latest version
      - **Option 2:** Specify the local file path
    - You will also be prompted to enter the icon filename (e.g., `cursor-icon.png` or `cursor-black-icon.png`).

3. **Launch Cursor**
    - After installation, find "Cursor AI IDE" in your application menu.
    - Or launch from terminal:
      ```zsh
      /opt/Cursor/AppRun --no-sandbox
      ```

---

## 🛠️ What the Script Does
- Installs or updates Cursor AI IDE
- Checks for and installs required tools (`curl`, `wget`, `jq`)
- Downloads and extracts the Cursor AppImage to `/opt/Cursor/`
- Downloads your chosen icon to `/opt/Cursor/`
- Creates a desktop entry for easy launching

---

## ❌ Uninstallation
To uninstall Cursor:
1. Remove the application files:
    ```zsh
    sudo rm -rf /opt/Cursor
    ```
2. Remove the desktop entry:
    ```zsh
    sudo rm -f /usr/share/applications/cursor.desktop
    ```

---

## 🧩 Troubleshooting
- Ensure you have `sudo` privileges and an active internet connection.
- Make sure the AppImage file path you provide is correct and accessible.
- Confirm the icon filename exists in the `images` directory of this repository.
- If Cursor fails to start, try running it from the terminal to see any error messages.
- Check script permissions (`chmod +x manage_cursor.sh`).

---

For questions or issues, please open an issue on this repository.
