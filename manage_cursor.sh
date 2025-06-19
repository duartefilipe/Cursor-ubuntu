#!/bin/bash

# --- Global Variables ---
# Change the install directory to a user home directory to avoid sudo in some steps
# Or keep /opt/Cursor if you want to install system-wide
CURSOR_EXTRACT_DIR="/opt/Cursor" # Directory to extract AppImage contents
ICON_FILENAME_ON_DISK="cursor-icon.png" # Standardized icon filename

# Paths based on the above directory
ICON_PATH="${CURSOR_EXTRACT_DIR}/${ICON_FILENAME_ON_DISK}"
# The executable is now AppRun inside the extracted directory
EXECUTABLE_PATH="${CURSOR_EXTRACT_DIR}/AppRun"
DESKTOP_ENTRY_PATH="/usr/share/applications/cursor.desktop"

# --- Download Latest Cursor AppImage Function ---
download_latest_cursor_appimage() {
    API_URL="https://www.cursor.com/api/download?platform=linux-x64&releaseTrack=stable"
    USER_AGENT="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36"
    DOWNLOAD_PATH="/tmp/latest-cursor.AppImage"
    FINAL_URL=$(curl -sL -A "$USER_AGENT" "$API_URL" | jq -r '.url // .downloadUrl')

    if [ -z "$FINAL_URL" ] || [ "$FINAL_URL" = "null" ]; then
        echo "==============================="
        echo "❌ Could not get the final AppImage URL from Cursor API."
        echo "ℹ️ Please try again later."
        echo "==============================="    
        return 1
    fi

    echo "Downloading latest Cursor AppImage from: $FINAL_URL"
    wget -q -O "$DOWNLOAD_PATH" "$FINAL_URL"

    if [ $? -eq 0 ] && [ -s "$DOWNLOAD_PATH" ]; then
        echo "==============================="
        echo "✅ Successfully downloaded Cursor AppImage!"
        echo "AppImage saved to: $DOWNLOAD_PATH" # Return the downloaded file path
        echo "==============================="
        return 0
    else
        echo "==============================="
        echo "❌ Failed to download the AppImage."
        echo "==============================="
        return 1
    fi
}

# --- Installation Function ---
installCursor() {
    if [ -d "$CURSOR_EXTRACT_DIR" ]; then
        echo "==============================="
        echo "❌ Cursor install directory already exists at $CURSOR_EXTRACT_DIR."
        echo "If you want to update, please choose the update option."
        echo "==============================="
        exec "$0"
    fi

    figlet -f slant "Install Cursor"
    echo "-------------------------------------------------"
    echo "Installing Cursor AI IDE on Ubuntu..."
    echo "How would you like to provide the Cursor AppImage?"
    echo "1. Auto-download the latest version from Cursor website (recommended)"
    echo "2. Specify a local file path"
    echo "-------------------------------------------------"
    read -p "Choose 1 or 2: " appimage_option

    local CURSOR_DOWNLOAD_PATH=""

    if [ "$appimage_option" = "1" ]; then
        # --- Check required tools ---
        for cmd in curl wget jq; do
            if ! command -v $cmd &> /dev/null; then
                echo "$cmd is not installed. Installing..."
                sudo apt-get update
                sudo apt-get install -y $cmd
            fi
        done
        # --- End check ---

        echo "⏳ Downloading the latest Cursor AppImage, please wait..."
        CURSOR_DOWNLOAD_PATH=$(download_latest_cursor_appimage | tail -n 1)
        if [ $? -ne 0 ] || [ ! -f "$CURSOR_DOWNLOAD_PATH" ]; then
            echo "==============================="
            echo "❌ Auto-download failed!"
            echo "==============================="
            echo "Would you like to specify the file path manually instead? (y/n):"
            read -r retry_option
            if [[ "$retry_option" =~ ^[Yy]$ ]]; then
                read -p "Enter the path to the Cursor AppImage on your computer: " CURSOR_DOWNLOAD_PATH
            else
                echo "Exiting installation."
                exit 1
            fi
        fi
    else
        read -p "Enter the path to the Cursor AppImage on your computer: " CURSOR_DOWNLOAD_PATH
    fi

    if [ ! -f "$CURSOR_DOWNLOAD_PATH" ]; then
        echo "==============================="
        echo "❌ No file found at: $CURSOR_DOWNLOAD_PATH"
        echo "==============================="
        exit 1
    fi

    # ===== MAIN EXTRACTION AND INSTALLATION =====
    echo "Granting execute permission to the AppImage..."
    chmod +x "$CURSOR_DOWNLOAD_PATH"

    echo "Extracting AppImage..."
    (cd /tmp && "$CURSOR_DOWNLOAD_PATH" --appimage-extract > /dev/null)
    if [ ! -d "/tmp/squashfs-root" ]; then
        echo "==============================="
        echo "❌ Failed to extract AppImage."
        echo "==============================="
        sudo rm -f "$CURSOR_DOWNLOAD_PATH"
        exit 1
    fi
    echo "Extraction successful!"

    echo "Creating installation directory ${CURSOR_EXTRACT_DIR}..."
    sudo mkdir -p "$CURSOR_EXTRACT_DIR"

    echo "Moving extracted contents to ${CURSOR_EXTRACT_DIR}..."
    sudo rsync -a --remove-source-files /tmp/squashfs-root/ "$CURSOR_EXTRACT_DIR/"
    echo "Files moved successfully."

    # Cleanup
    sudo rm -f "$CURSOR_DOWNLOAD_PATH"
    sudo rm -rf /tmp/squashfs-root

    # --- Download Icon and create Desktop Entry ---
    read -p "Enter the icon filename from GitHub (e.g., cursor-icon.png): " ICON_NAME_FROM_GITHUB
    ICON_DOWNLOAD_URL="https://raw.githubusercontent.com/hieutt192/Cursor-ubuntu/main/images/$ICON_NAME_FROM_GITHUB"
    echo "Downloading icon to $ICON_PATH..."
    sudo curl -L "$ICON_DOWNLOAD_URL" -o "$ICON_PATH"

    echo "Creating a .desktop entry for Cursor..."
    sudo bash -c "cat > \"$DESKTOP_ENTRY_PATH\"" <<EOL
[Desktop Entry]
Name=Cursor AI IDE
Exec=${EXECUTABLE_PATH} --no-sandbox
Icon=${ICON_PATH}
Type=Application
Categories=Development;
EOL

    echo "================================"
    echo "✅ Cursor AI IDE installation complete. Desktop entry was created successfully."
    echo "You can find Cursor in your applications menu."
    echo "================================"
}

# --- Update Function ---
updateCursor() {
    if [ ! -d "$CURSOR_EXTRACT_DIR" ]; then
        echo "==============================="
        echo "❌ Cursor is not installed. Please choose the installation option."
        echo "==============================="
        return
    fi

    figlet -f slant "Update Cursor"
    echo "-------------------------------------------------"
    echo "Updating Cursor AI IDE..."
    echo "How would you like to provide the new Cursor AppImage?"
    echo "1. Auto-download the latest version"
    echo "2. Specify a local file path"
    echo "-------------------------------------------------"
    read -p "Choose 1 or 2: " appimage_option

    local CURSOR_DOWNLOAD_PATH=""

    if [ "$appimage_option" = "1" ]; then
        echo "⏳ Downloading the latest Cursor AppImage, please wait..."
        CURSOR_DOWNLOAD_PATH=$(download_latest_cursor_appimage | tail -n 1)
        if [ $? -ne 0 ] || [ ! -f "$CURSOR_DOWNLOAD_PATH" ]; then
            echo "==============================="
            echo "❌ Auto-download failed!"
            echo "==============================="
            exit 1
        fi
    else
        read -p "Enter the path to the new Cursor AppImage on your computer: " CURSOR_DOWNLOAD_PATH
    fi

    if [ ! -f "$CURSOR_DOWNLOAD_PATH" ]; then
        echo "==============================="
        echo "❌ No file found at: $CURSOR_DOWNLOAD_PATH"
        echo "==============================="
        exit 1
    fi

    # ===== Extraction and replacement logic =====
    echo "Granting execute permission to the new AppImage..."
    chmod +x "$CURSOR_DOWNLOAD_PATH"

    echo "Extracting new AppImage..."
    (cd /tmp && "$CURSOR_DOWNLOAD_PATH" --appimage-extract > /dev/null)
    if [ ! -d "/tmp/squashfs-root" ]; then
        echo "==============================="
        echo "❌ Failed to extract new AppImage."
        echo "==============================="
        sudo rm -f "$CURSOR_DOWNLOAD_PATH"
        exit 1
    fi

    echo "Removing old version at ${CURSOR_EXTRACT_DIR}..."
    sudo rm -rf "${CURSOR_EXTRACT_DIR:?}"/*

    echo "Moving new version to ${CURSOR_EXTRACT_DIR}..."
    sudo rsync -a --remove-source-files /tmp/squashfs-root/ "$CURSOR_EXTRACT_DIR/"

    # Cleanup
    sudo rm -f "$CURSOR_DOWNLOAD_PATH"
    sudo rm -rf /tmp/squashfs-root

    echo "==============================="
    echo "✅ Cursor AI IDE update complete."
    echo "==============================="
}

# --- Main Menu ---
# Ensure figlet is installed for banner
if ! command -v figlet &> /dev/null; then
    echo "figlet is not installed. Installing..."
    sudo apt-get update
    sudo apt-get install -y figlet
fi

figlet -f slant "Cursor AI IDE"
echo "For Ubuntu 24.04 LTS"
echo "-------------------------------------------------"
echo "  /\\_/\\"
echo " ( o.o )"
echo "  > ^ <"
echo "-------------------------------------------------"
echo "1. Install Cursor"
echo "2. Update Cursor"
echo "-------------------------------------------------"

read -p "Please choose an option (1 or 2): " choice

case $choice in
    1)
        installCursor
        ;;
    2)
        updateCursor
        ;;
    *)
        echo "==============================="
        echo "❌ Invalid option. Exiting."
        echo "==============================="
        exit 1
        ;;
esac

exit 0