#!/bin/bash
# ============================
# ROM FLASHER (Linux Version)
# ============================

# ============================
# Function: Animated Dots
# ============================
sleep_dots() {
    for i in 1 2 3; do
        echo -n "."
        sleep 1
    done
    echo
}

echo "============================="
echo "         ROM FLASHER         "
echo "============================="
echo
echo "Device: Tecno Spark 30C (KL8H)"
echo "Rom: Rom Version"
echo "Android version: Android Version"
echo "Build Date: Build Date"
echo "Developer: Ayu Kashyap - @dev_ayu"
echo

echo ">> Allow the ADB popup on your phone if prompted."
read -rp "Press Enter to continue..."

echo
echo -n ">> Rebooting to Fastboot Mode..."
adb reboot fastboot >/dev/null 2>&1
sleep_dots

echo
echo -n ">> Formatting data..."
fastboot -w >/dev/null 2>&1
sleep_dots

echo
echo -n ">> Erasing system..."
fastboot erase system >/dev/null 2>&1
sleep_dots

echo -n ">> Deleting product_cow..."
fastboot delete-logical-partition product_cow >/dev/null 2>&1
sleep_dots

echo -n ">> Deleting product_a..."
fastboot delete-logical-partition product_a >/dev/null 2>&1
sleep_dots

echo -n ">> Deleting product..."
fastboot delete-logical-partition product >/dev/null 2>&1
sleep_dots

echo -n ">> Deleting system_ext..."
fastboot delete-logical-partition system_ext >/dev/null 2>&1
sleep_dots

echo -n ">> Deleting system_ext_a..."
fastboot delete-logical-partition system_ext_a >/dev/null 2>&1
sleep_dots

echo
echo -n ">> Flashing system image..."
fastboot flash system images/system.img >/dev/null 2>&1
sleep_dots

echo
echo ">> ROM flashed successfully."
echo

# ============================
# Ask for root/unroot choice
# ============================
while true; do
    echo "Select boot method:"
    echo "1) Magisk"
    echo "2) Apatch"
    echo "3) Unroot (Stock Boot)"
    read -rp "Enter choice (1/2/3): " choice

    case "$choice" in
        1)
            echo
            echo -n ">> Installing Magisk..."
            fastboot flash boot images/boot_5.15.188.img >/dev/null 2>&1
            fastboot reboot bootloader >/dev/null 2>&1
            sudo fastboot flash init_boot_a images/init_boot_a_magisk.img >/dev/null 2>&1
            fastboot --disable-verity --disable-verification flash vbmeta_a images/vbmeta_a.img >nul 2>&1
            fastboot --disable-verity --disable-verification flash vbmeta_system_a images/vbmeta_system_a.img >nul 2>&1
            sleep_dots
            echo ">> Magisk installed successfully."
            break
            ;;
        2)
            echo
            echo -n ">> Installing Apatch..."
            fastboot flash boot images/boot_5.15.188_apatch.img >/dev/null 2>&1
            fastboot reboot bootloader >/dev/null 2>&1
            sudo fastboot flash init_boot_a images/init_boot_a.img >/dev/null 2>&1
            fastboot --disable-verity --disable-verification flash vbmeta_a images/vbmeta_a.img >nul 2>&1
            fastboot --disable-verity --disable-verification flash vbmeta_system_a images/vbmeta_system_a.img >nul 2>&1
            sleep_dots
            echo ">> Apatch installed successfully."
            break
            ;;
        3)
            echo
            echo -n ">> Flashing stock boot (Unroot)..."
            fastboot flash boot images/boot_5.15.188.img >/dev/null 2>&1
            fastboot reboot bootloader >/dev/null 2>&1
            sudo fastboot flash init_boot_a images/init_boot_a.img >/dev/null 2>&1
            fastboot --disable-verity --disable-verification flash vbmeta_a images/vbmeta_a.img >nul 2>&1
            fastboot --disable-verity --disable-verification flash vbmeta_system_a images/vbmeta_system_a.img >nul 2>&1
            sleep_dots
            echo ">> Stock boot flashed (Unrooted)."
            break
            ;;
        *)
            echo "Invalid choice. Please enter 1, 2, or 3."
            ;;
    esac
done

# ============================
# Final reboot
# ============================
echo
echo -n ">> Rebooting device now..."
fastboot reboot >/dev/null 2>&1
sleep_dots
echo
read -rp "Press Enter to exit..."

