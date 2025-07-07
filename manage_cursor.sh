#!/bin/bash
#
# Install / Update script for Cursor AI IDE on Ubuntu 24.04+
# ───────────────────────────────────────────────────────────

# ── Global Variables ───────────────────────────────────────
CURSOR_EXTRACT_DIR="/opt/Cursor"                   # Where the AppImage is extracted
ICON_FILENAME_ON_DISK="cursor-icon.png"            # Main icon name
ALT_ICON_FILENAME_ON_DISK="cursor-black-icon.png"  # Secondary icon (dark variant)
ICON_PATH="${CURSOR_EXTRACT_DIR}/${ICON_FILENAME_ON_DISK}"
EXECUTABLE_PATH="${CURSOR_EXTRACT_DIR}/AppRun"     # Main executable after extract
DESKTOP_ENTRY_PATH="/usr/share/applications/cursor.desktop"

# ── Download latest Cursor AppImage ───────────────────────
download_latest_cursor_appimage() {
    API_URL="https://www.cursor.com/api/download?platform=linux-x64&releaseTrack=stable"
    USER_AGENT="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36"
    DOWNLOAD_PATH="/tmp/latest-cursor.AppImage"

    FINAL_URL=$(curl -sL -A "$USER_AGENT" "$API_URL" | jq -r '.url // .downloadUrl')
    if [ -z "$FINAL_URL" ] || [ "$FINAL_URL" = "null" ]; then
        echo "❌ Could not retrieve the final AppImage URL from the Cursor API." >&2
        return 1
    fi

    echo "Downloading the latest Cursor AppImage from: $FINAL_URL"
    wget -q -O "$DOWNLOAD_PATH" "$FINAL_URL"
    if [ $? -eq 0 ] && [ -s "$DOWNLOAD_PATH" ]; then
        echo "✅ Successfully downloaded the Cursor AppImage!" >&2
        echo "$DOWNLOAD_PATH"
        return 0
    else
        echo "❌ Failed to download the AppImage." >&2
        return 1
    fi
}

# ── Installation ──────────────────────────────────────────
installCursor() {
    if [ -d "$CURSOR_EXTRACT_DIR" ]; then
        echo "==============================="
        echo "ℹ️  Cursor is already installed at $CURSOR_EXTRACT_DIR."
        echo "    Choose the Update option instead."
        echo "==============================="
        exec "$0"
    fi

    figlet -f slant "Install Cursor"
    echo "Installing Cursor AI IDE on Ubuntu..."
    echo "How would you like to provide the Cursor AppImage?"
    echo "1. Automatically download the latest version (recommended)"
    echo "2. Specify an existing file path"
    echo "-------------------------------------------------"
    read -rp "Choose 1 or 2: " appimage_option

    local CURSOR_DOWNLOAD_PATH=""
    if [ "$appimage_option" = "1" ]; then
        for cmd in curl wget jq; do
            if ! command -v "$cmd" &>/dev/null; then
                echo "$cmd is not installed. Installing..."
                sudo apt-get update
                sudo apt-get install -y "$cmd"
            fi
        done
        echo "⏳ Downloading the latest Cursor AppImage..."
        CURSOR_DOWNLOAD_PATH=$(download_latest_cursor_appimage | tail -n 1)
        if [ $? -ne 0 ] || [ ! -f "$CURSOR_DOWNLOAD_PATH" ]; then
            echo "==============================="
            echo "❌ Automatic download failed!"
            echo "==============================="
            read -rp "Would you like to specify the file path manually? (y/n) " retry_option
            if [[ "$retry_option" =~ ^[Yy]$ ]]; then
                read -rp "Enter the Cursor AppImage file path: " CURSOR_DOWNLOAD_PATH
            else
                echo "Exiting installation."
                exit 1
            fi
        fi
    else
        read -rp "Enter the Cursor AppImage file path: " CURSOR_DOWNLOAD_PATH
    fi

    if [ ! -f "$CURSOR_DOWNLOAD_PATH" ]; then
        echo "==============================="
        echo "❌ File does not exist at: $CURSOR_DOWNLOAD_PATH"
        echo "==============================="
        exit 1
    fi

    chmod +x "$CURSOR_DOWNLOAD_PATH"
    echo "Extracting AppImage..."
    (cd /tmp && "$CURSOR_DOWNLOAD_PATH" --appimage-extract > /dev/null)
    if [ ! -d "/tmp/squashfs-root" ]; then
        echo "==============================="
        echo "❌ Failed to extract the AppImage."
        echo "==============================="
        sudo rm -f "$CURSOR_DOWNLOAD_PATH"
        exit 1
    fi
    echo "✅ Extraction successful!"

    echo "Creating installation directory at ${CURSOR_EXTRACT_DIR}..."
    sudo mkdir -p "$CURSOR_EXTRACT_DIR"
    sudo rsync -a --remove-source-files /tmp/squashfs-root/ "$CURSOR_EXTRACT_DIR/"

    sudo rm -f "$CURSOR_DOWNLOAD_PATH"
    sudo rm -rf /tmp/squashfs-root

    # ── Icon & desktop entry ───────────────────────────────────────────────
    read -rp "Enter the icon filename from GitHub (e.g. cursor-icon.png): " ICON_NAME_FROM_GITHUB
    ICON_DOWNLOAD_URL="https://raw.githubusercontent.com/hieutt192/Cursor-ubuntu/main/images/$ICON_NAME_FROM_GITHUB"
    echo "Downloading icon to $ICON_PATH..."
    sudo curl -L "$ICON_DOWNLOAD_URL" -o "$ICON_PATH"

    sudo tee "$DESKTOP_ENTRY_PATH" >/dev/null <<EOL
[Desktop Entry]
Name=Cursor AI IDE
Exec=${EXECUTABLE_PATH} --no-sandbox
Icon=${ICON_PATH}
Type=Application
Categories=Development;
EOL

    echo "==============================="
    echo "✅ Cursor AI IDE installation complete!"
    echo "==============================="
}

# ── Update ─────────────────────────────────────────────────
updateCursor() {
    if [ ! -d "$CURSOR_EXTRACT_DIR" ]; then
        echo "==============================="
        echo "❌ Cursor is not installed. Please run the installer first."
        echo "==============================="
        return
    fi

    figlet -f slant "Update Cursor"
    echo "Updating Cursor AI IDE..."
    echo "How would you like to provide the new Cursor AppImage?"
    echo "1. Automatically download the latest version"
    echo "2. Specify an existing file path"
    echo "-------------------------------------------------"
    read -rp "Choose 1 or 2: " appimage_option

    local CURSOR_DOWNLOAD_PATH=""
    if [ "$appimage_option" = "1" ]; then
        echo "⏳ Downloading the latest Cursor AppImage..."
        CURSOR_DOWNLOAD_PATH=$(download_latest_cursor_appimage | tail -n 1)
        if [ $? -ne 0 ] || [ ! -f "$CURSOR_DOWNLOAD_PATH" ]; then
            echo "==============================="
            echo "❌ Automatic download failed!"
            echo "==============================="
            exit 1
        fi
    else
        read -rp "Enter the new Cursor AppImage file path: " CURSOR_DOWNLOAD_PATH
    fi

    if [ ! -f "$CURSOR_DOWNLOAD_PATH" ]; then
        echo "==============================="
        echo "❌ File does not exist at: $CURSOR_DOWNLOAD_PATH"
        echo "==============================="
        exit 1
    fi

    chmod +x "$CURSOR_DOWNLOAD_PATH"
    echo "Extracting new AppImage..."
    (cd /tmp && "$CURSOR_DOWNLOAD_PATH" --appimage-extract > /dev/null)
    if [ ! -d "/tmp/squashfs-root" ]; then
        echo "==============================="
        echo "❌ Failed to extract the new AppImage."
        echo "==============================="
        sudo rm -f "$CURSOR_DOWNLOAD_PATH"
        exit 1
    fi

    # ── Preserve icon(s) ────────────────────────────────
    ICON_BACKUP_DIR="/tmp/cursor_icon_backup.$$"
    mkdir -p "$ICON_BACKUP_DIR"
    for ICON_FILE in "$ICON_FILENAME_ON_DISK" "$ALT_ICON_FILENAME_ON_DISK"; do
        if [ -f "${CURSOR_EXTRACT_DIR}/${ICON_FILE}" ]; then
            cp "${CURSOR_EXTRACT_DIR}/${ICON_FILE}" "${ICON_BACKUP_DIR}/"
        fi
    done

    echo "Removing old version at ${CURSOR_EXTRACT_DIR}..."
    sudo rm -rf "${CURSOR_EXTRACT_DIR:?}"/*

    echo "Deploying new version..."
    sudo rsync -a --remove-source-files /tmp/squashfs-root/ "$CURSOR_EXTRACT_DIR/"

    # ── Restore icon(s) ────────────────────────────────
    for ICON_FILE in "$ICON_FILENAME_ON_DISK" "$ALT_ICON_FILENAME_ON_DISK"; do
        if [ -f "${ICON_BACKUP_DIR}/${ICON_FILE}" ]; then
            sudo mv "${ICON_BACKUP_DIR}/${ICON_FILE}" "${CURSOR_EXTRACT_DIR}/${ICON_FILE}"
        fi
    done
    rm -rf "$ICON_BACKUP_DIR"

    sudo rm -f "$CURSOR_DOWNLOAD_PATH"
    sudo rm -rf /tmp/squashfs-root

    echo "==============================="
    echo "✅ Cursor AI IDE update complete!"
    echo "==============================="
}

# ── Main Menu ─────────────────────────────────────────────
if ! command -v figlet &>/dev/null; then
    echo "figlet is not installed. Installing..."
    sudo apt-get update
    sudo apt-get install -y figlet
fi

figlet -f slant "Cursor AI IDE"
echo "Ubuntu 24.04 compatible"
echo "-------------------------------------------------"
echo "  /\\_/\\"
echo " ( o.o )"
echo "  > ^ <"
echo "---------------------------"
echo "1. Install Cursor"
echo "2. Update Cursor"
echo "Note: If the menu reappears after choosing 1 or 2, check any error message above."
echo "-------------------------------------------------"
read -rp "Choose an option (1 or 2): " choice

case "$choice" in
    1) installCursor ;;
    2) updateCursor  ;;
    *) echo "==============================="
       echo "❌ Invalid option. Exiting."
       echo "==============================="
       exit 1 ;;
esac

exit 0
