#!/bin/bash

# ==============================================================================
# Cursor AI IDE Manager for Ubuntu & Elementary OS
# ==============================================================================

# --- Global Configuration ---
CURSOR_INSTALL_DIR="/opt/Cursor"
APPIMAGE_FILENAME="cursor.AppImage"
ICON_FILENAME_ON_DISK="cursor-icon.png"

# Derived paths
APPIMAGE_PATH="${CURSOR_INSTALL_DIR}/${APPIMAGE_FILENAME}"
ICON_PATH="${CURSOR_INSTALL_DIR}/${ICON_FILENAME_ON_DISK}"
DESKTOP_ENTRY_PATH="/usr/share/applications/cursor.desktop"

# Flags
INTERACTIVE=true
ACTION="" # "install", "update", "uninstall"

# --- Utility Functions ---

print_error() {
    echo -e "\033[0;31m❌ [ERROR] $1\033[0m" >&2
}

print_success() {
    echo -e "\033[0;32m✅ [SUCCESS] $1\033[0m"
}

print_info() {
    echo -e "\033[0;34mℹ️  [INFO] $1\033[0m"
}

print_warn() {
    echo -e "\033[0;33m⚠️  [WARNING] $1\033[0m"
}

# Cleanup temporary files on exit
cleanup() {
    if [ -f "/tmp/cursor_latest.AppImage" ]; then
        rm -f "/tmp/cursor_latest.AppImage"
    fi
}
trap cleanup EXIT

# --- System Checks ---

check_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        # Elementary OS usually has ID=elementary and ID_LIKE=ubuntu
        if [[ "$ID" == "ubuntu" ]] || [[ "$ID" == "elementary" ]] || [[ "$ID_LIKE" == *"ubuntu"* ]]; then
            # Valid OS
            return 0
        else
            print_warn "This script was designed for Ubuntu/Elementary OS. Detected: ${PRETTY_NAME:-Unknown}"
            print_warn "Proceeding, but it may not work as expected."
        fi
    else
        print_warn "Could not detect OS version. Proceeding with caution."
    fi
}

install_dependencies() {
    local deps=("curl" "jq" "wget" "figlet")
    local missing_deps=()

    print_info "Checking dependencies..."
    
    # Update package list first to avoid 'package not found' errors
    # Only run if we actually suspect we need to install something or if we haven't updated recently?
    # Safer to run it if we find missing deps.
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing_deps+=("$dep")
        fi
    done
    
    # Check libfuse2 (needed for AppImage on >= 22.04)
    if ! dpkg -s libfuse2 &> /dev/null; then
        missing_deps+=("libfuse2")
    fi

    if [ ${#missing_deps[@]} -ne 0 ]; then
        print_info "Installing missing dependencies: ${missing_deps[*]}"
        print_info "Running apt-get update..."
        sudo apt-get update -qq
        
        sudo apt-get install -y "${missing_deps[@]}"
        
        if [ $? -ne 0 ]; then
            print_error "Failed to install dependencies. Please check your internet connection or package manager."
            return 1 # Allow caller to handle exit
        fi
    else
        print_success "All dependencies are installed."
    fi
}

# --- Core Operations ---

download_latest_url() {
    # Using the official download endpoint which redirects to the latest version
    local api_url="https://www.cursor.com/api/download?platform=linux-x64&releaseTrack=stable"
    # User agent is important sometimes to avoid being blocked or getting wrong content
    local user_agent="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36"
    
    local final_url
    # Try to get the URL from the redirection or JSON if it returns that
    # The current API returns a JSON with downloadUrl or direct redirect.
    # Let's try getting the header location first (more robust for redirects)
    
    final_url=$(curl -sL -A "$user_agent" "$api_url" | jq -r '.url // .downloadUrl')
    
    if [ -z "$final_url" ] || [ "$final_url" = "null" ]; then
        # Fallback: sometimes the API just returns the file directly (binary).
        # But we need the URL for wget.
        # Let's assume the previous method works as it was in the original script and is standard for Electron updaters.
        print_error "Could not retrieve download URL."
        return 1
    fi
    echo "$final_url"
}

download_appimage() {
    local download_target="/tmp/cursor_latest.AppImage"
    local url
    
    print_info "Fetching latest version URL..."
    url=$(download_latest_url)
    
    if [ -z "$url" ]; then
        print_error "Failed to retrieve download URL from Cursor API."
        print_info "Please check your internet connection or try again later."
        return 1
    fi

    print_info "Downloading AppImage from $url..."
    wget -q --show-progress -O "$download_target" "$url"
    
    if [ $? -ne 0 ] || [ ! -s "$download_target" ]; then
        print_error "Download failed."
        return 1
    fi

    # Basic verification
    if ! file "$download_target" | grep -q "ELF"; then
        print_error "Downloaded file is not a valid executable."
        print_info "File type detected: $(file "$download_target")"
        return 1
    fi

    echo "$download_target"
}

install_cursor() {
    # Check if already installed
    if [ -f "$APPIMAGE_PATH" ]; then
        print_info "Cursor appears to be installed."
        if [ "$INTERACTIVE" = true ]; then
            read -rp "Do you want to reinstall/update? (y/N): " choice
            if [[ ! "$choice" =~ ^[Yy]$ ]]; then
                print_info "Aborting installation."
                return 0
            fi
        else
             print_info "Reinstalling (Non-interactive)..."
        fi
    fi

    install_dependencies || exit 1

    local new_appimage
    new_appimage=$(download_appimage)
    if [ $? -ne 0 ]; then
        exit 1
    fi

    print_info "Installing to $CURSOR_INSTALL_DIR..."
    
    # Create dir if not exists
    if [ ! -d "$CURSOR_INSTALL_DIR" ]; then
        sudo mkdir -p "$CURSOR_INSTALL_DIR"
    fi

    # Move AppImage
    sudo mv "$new_appimage" "$APPIMAGE_PATH"
    sudo chmod 755 "$APPIMAGE_PATH"

    # Install Icon
    local icon_url="https://raw.githubusercontent.com/hieutt192/Cursor-ubuntu/main/images/cursor-icon.png"
    print_info "Downloading icon..."
    sudo curl -sL "$icon_url" -o "$ICON_PATH"

    # Create Desktop Entry
    print_info "Creating desktop entry..."
    sudo tee "$DESKTOP_ENTRY_PATH" >/dev/null <<EOL
[Desktop Entry]
Name=Cursor AI IDE
Exec=$APPIMAGE_PATH --no-sandbox %F
Icon=$ICON_PATH
Type=Application
Categories=Development;
MimeType=x-scheme-handler/cursor;
Terminal=false
StartupWMClass=Cursor
EOL
    sudo chmod 644 "$DESKTOP_ENTRY_PATH"

    print_success "Cursor installed successfully!"
    print_info "You may need to log out/in or run 'update-desktop-database' for the menu to update."
}

update_cursor() {
    if [ ! -f "$APPIMAGE_PATH" ]; then
        print_warn "Cursor is not installed. Switching to install mode."
        install_cursor
        return
    fi

    install_dependencies || exit 1

    print_info "Starting Atomic Update..."
    local new_appimage
    new_appimage=$(download_appimage)
    if [ $? -ne 0 ]; then
        print_error "Update aborted due to download failure."
        exit 1
    fi

    print_info "Applying update..."
    # Atomic swap
    sudo mv "$new_appimage" "$APPIMAGE_PATH"
    sudo chmod 755 "$APPIMAGE_PATH"

    print_success "Update complete!"
}

uninstall_cursor() {
    if [ ! -f "$APPIMAGE_PATH" ] && [ ! -f "$DESKTOP_ENTRY_PATH" ]; then
        print_warn "Cursor does not appear to be installed."
        return 0
    fi

    if [ "$INTERACTIVE" = true ]; then
        echo -e "\033[0;31m⚠️  This will remove Cursor AppImage and Desktop entry.\033[0m"
        echo "Your settings and config (~/.config/Cursor) will remain."
        read -rp "Are you sure? (y/N): " confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            print_info "Uninstall cancelled."
            return 0
        fi
    fi

    print_info "Removing files..."
    if [ -d "$CURSOR_INSTALL_DIR" ]; then
        sudo rm -rf "$CURSOR_INSTALL_DIR"
    fi
    
    if [ -f "$DESKTOP_ENTRY_PATH" ]; then
        sudo rm -f "$DESKTOP_ENTRY_PATH"
    fi

    print_success "Uninstall complete."
}

show_menu() {
    check_os
    
    if command -v figlet &> /dev/null; then
        figlet -f slant "Cursor Manager"
    else
        echo "=== Cursor Manager ==="
    fi

    echo "1. 💿 Install Cursor"
    echo "2. 🆙 Update Cursor"
    echo "3. 🗑️  Uninstall Cursor"
    echo "4. 🚪 Exit"
    echo "------------------------"
    
    read -rp "Select an option [1-4]: " selection
    
    case $selection in
        1) install_cursor ;;
        2) update_cursor ;;
        3) uninstall_cursor ;;
        4) exit 0 ;;
        *) print_error "Invalid option"; exit 1 ;;
    esac
}

# --- CLI Argument Parsing ---
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -i|--install) ACTION="install"; INTERACTIVE=false ;;
        -u|--update) ACTION="update"; INTERACTIVE=false ;;
        -r|--remove|--uninstall) ACTION="uninstall"; INTERACTIVE=false ;;
        -h|--help) 
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  -i, --install    Install Cursor"
            echo "  -u, --update     Update Cursor"
            echo "  --uninstall      Uninstall Cursor"
            echo "  -h, --help       Show this help"
            exit 0
            ;;
        *) print_error "Unknown parameter: $1"; exit 1 ;;
    esac
    shift
done

# --- Main Execution ---

if [ -n "$ACTION" ]; then
    check_os
    case "$ACTION" in
        install) install_cursor ;;
        update) update_cursor ;;
        uninstall) uninstall_cursor ;;
    esac
else
    show_menu
fi
