#!/bin/bash
# Dependency Installer for Linux

echo "[1/2] Checking for Python..."
if ! command -v python3 &> /dev/null; then
    echo
    echo "[ERROR] Python 3 is not installed."
    echo "Please install it using your package manager."
    echo "Example (Debian/Ubuntu): sudo apt update && sudo apt install python3"
    echo "Example (Arch/Manjaro): sudo pacman -S python"
    exit 1
fi
echo "     Python found."
echo

echo "[2/2] Checking for Android Platform Tools (ADB/Fastboot)..."
if command -v adb &> /dev/null && command -v fastboot &> /dev/null; then
    echo "     Platform Tools already installed. Setup is complete."
else
    echo "     Platform Tools not found. Attempting to install..."
    if command -v apt-get &> /dev/null; then
        echo "     Detected Debian/Ubuntu based system. Using apt..."
        sudo apt-get update
        sudo apt-get install -y adb fastboot
    elif command -v pacman &> /dev/null; then
        echo "     Detected Arch based system. Using pacman..."
        sudo pacman -Syu --noconfirm android-tools
    else
        echo "[ERROR] Could not detect package manager."
        echo "Please install 'adb' and 'fastboot' (often in a package like 'android-tools') manually."
        exit 1
    fi
    echo "     Platform Tools installed successfully."
fi

echo
echo "================================="
echo "  Setup complete!"
echo "  You can now run installer.py"
echo "================================="
echo
