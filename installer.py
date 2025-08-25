import os
import sys
import subprocess
import time
import shutil

# --- Configuration ---
# Fill in the details for the ROM you are flashing
ROM_VERSION = "Name of your ROM v1.0"
ANDROID_VERSION = "14.0 (U)"
BUILD_DATE = "YYYY-MM-DD"
BOOT_VERSION = "5.15.188" # Kernel version for boot images

# Define the folder where your .img files are located
IMAGES_FOLDER = "images"
# -------------------

def clear_screen():
    """Clears the console screen."""
    os.system('cls' if os.name == 'nt' else 'clear')

def animated_dots(text, duration=0.8):
    """Prints a message followed by animated dots."""
    print(f">> {text}", end="", flush=True)
    for _ in range(3):
        time.sleep(duration)
        print(".", end="", flush=True)
    print()

def run_command(command_list):
    """Runs an external command and hides its output, checking for image files."""
    try:
        # Before running, check if any image file in the command exists
        for item in command_list:
            if isinstance(item, str) and item.endswith('.img'):
                if not os.path.exists(item):
                    print(f"\n[ERROR] Image file not found: {item}")
                    print(f"Please make sure it exists in the '{IMAGES_FOLDER}' folder.")
                    return False
        
        subprocess.run(command_list, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        return True
    except (subprocess.CalledProcessError, FileNotFoundError) as e:
        # Provide more specific feedback for common fastboot errors
        cmd_str = ' '.join(command_list)
        if 'delete-logical-partition' in cmd_str and isinstance(e, subprocess.CalledProcessError):
             # This error is often non-critical (partition didn't exist), so we can ignore it.
             print(f"\n   (Note: Could not delete partition, it may not have existed. This is usually safe.)")
             return True
        print(f"\n[ERROR] Failed to execute command: {cmd_str}")
        print(f"        Details: {e}")
        return False

def check_dependencies():
    """Checks if adb and fastboot are available."""
    print(">> Checking for ADB and Fastboot dependencies...")
    adb_path = shutil.which("adb")
    fastboot_path = shutil.which("fastboot")

    if os.name == 'nt':
        local_adb = os.path.join("platform-tools", "adb.exe")
        local_fastboot = os.path.join("platform-tools", "fastboot.exe")
        if os.path.exists(local_adb): adb_path = local_adb
        if os.path.exists(local_fastboot): fastboot_path = local_fastboot

    if not adb_path or not fastboot_path:
        print("\n[ERROR] ADB or Fastboot not found!")
        print("Please run the appropriate setup script for your OS first:")
        print("- On Windows: run setup.bat")
        print("- On Linux:   run setup.sh")
        input("\nPress Enter to exit...")
        sys.exit(1)
        
    print(">> Dependencies found successfully.")
    time.sleep(1)
    return adb_path, fastboot_path

def main():
    """Main function to run the ROM flasher."""
    clear_screen()
    adb, fastboot = check_dependencies()

    fastboot_cmd = [fastboot]
    if sys.platform.startswith('linux'):
        try:
            subprocess.run([fastboot, "--version"], check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        except (subprocess.CalledProcessError, PermissionError):
            print(">> Fastboot requires root privileges. Using 'sudo'.")
            fastboot_cmd.insert(0, "sudo")

    # --- Header ---
    clear_screen()
    print("=============================")
    print("         ROM FLASHER         ")
    print("=============================")
    print(f"Device:        Tecno Spark 30C (KL8H)")
    print(f"Rom:           {ROM_VERSION}")
    print(f"Android:       {ANDROID_VERSION}")
    print(f"Build Date:    {BUILD_DATE}")
    print(f"Developer:     Ayu Kashyap - @dev_ayu")
    print("\n>> Allow the ADB popup on your phone if prompted.")
    input("Press Enter to continue...")

    # --- Initial Steps ---
    print()
    animated_dots("Rebooting to Fastboot Mode")
    if not run_command([adb, "reboot", "fastboot"]): sys.exit(1)
    time.sleep(5)

    # --- Wiping & Flashing ---
    animated_dots("Formatting data", duration=1.5)
    if not run_command(fastboot_cmd + ["-w"]): sys.exit(1)
    
    animated_dots("Erasing system")
    if not run_command(fastboot_cmd + ["erase", "system"]): sys.exit(1)

    print("\n>> Deleting logical partitions...")
    partitions_to_delete = ["product_cow", "product_a", "product", "system_ext", "system_ext_a"]
    for partition in partitions_to_delete:
        print(f"   - Deleting {partition}...")
        run_command(fastboot_cmd + ["delete-logical-partition", partition])
    
    print()
    animated_dots("Flashing system image", duration=3)
    system_img = os.path.join(IMAGES_FOLDER, "system.img")
    if not run_command(fastboot_cmd + ["flash", "system", system_img]): sys.exit(1)

    print("\n>> ROM flashed successfully.")

    # --- Root Selection Menu ---
    while True:
        print("\nSelect a boot method:")
        print("[1] Magisk")
        print("[2] Apatch")
        print("[3] KSU Next (KernelSU Next)")
        print("[4] Unroot (Stock Boot)")
        choice = input("Enter choice (1/2/3/4): ")
        if choice in ["1", "2", "3", "4"]:
            break
        print("Invalid choice. Please enter 1, 2, 3, or 4.")

    # --- Define Image Paths ---
    boot_magisk = os.path.join(IMAGES_FOLDER, f"boot_{BOOT_VERSION}.img")
    boot_apatch = os.path.join(IMAGES_FOLDER, f"boot_{BOOT_VERSION}_apatch.img")
    boot_stock = os.path.join(IMAGES_FOLDER, f"boot_{BOOT_VERSION}.img")
    init_boot_magisk = os.path.join(IMAGES_FOLDER, "init_boot_a_magisk.img")
    init_boot_ksu = os.path.join(IMAGES_FOLDER, "init_boot_a_ksu.img")
    init_boot_stock = os.path.join(IMAGES_FOLDER, "init_boot_a.img")
    vbmeta_a_img = os.path.join(IMAGES_FOLDER, "vbmeta_a.img")
    vbmeta_system_a_img = os.path.join(IMAGES_FOLDER, "vbmeta_system_a.img")
    
    boot_to_flash = ""
    init_boot_to_flash = ""

    if choice == "1": # Magisk
        animated_dots("Installing Magisk")
        boot_to_flash = boot_magisk
        init_boot_to_flash = init_boot_magisk
    elif choice == "2": # Apatch
        animated_dots("Installing Apatch")
        boot_to_flash = boot_apatch
        init_boot_to_flash = init_boot_stock
    elif choice == "3": # KSU
        animated_dots("Installing KSU Next")
        boot_to_flash = boot_stock
        init_boot_to_flash = init_boot_ksu
    elif choice == "4": # Unroot
        animated_dots("Flashing stock boot (Unroot)")
        boot_to_flash = boot_stock
        init_boot_to_flash = init_boot_stock

    # --- Final Flashing Steps ---
    if not run_command(fastboot_cmd + ["flash", "boot", boot_to_flash]): sys.exit(1)
    if not run_command(fastboot_cmd + ["reboot", "bootloader"]): sys.exit(1)
    time.sleep(5)
    if not run_command(fastboot_cmd + ["flash", "init_boot_a", init_boot_to_flash]): sys.exit(1)
    
    vbmeta_flags = ["--disable-verity", "--disable-verification"]
    if not run_command(fastboot_cmd + vbmeta_flags + ["flash", "vbmeta_a", vbmeta_a_img]): sys.exit(1)
    if not run_command(fastboot_cmd + vbmeta_flags + ["flash", "vbmeta_system_a", vbmeta_system_a_img]): sys.exit(1)
    
    if choice == "1": print(">> Magisk installed successfully.")
    elif choice == "2": print(">> Apatch installed successfully.")
    elif choice == "3": print(">> KSU Next installed successfully.")
    elif choice == "4": print(">> Stock boot flashed (Unrooted).")

    # --- Final Reboot ---
    print()
    animated_dots("Rebooting device now")
    if not run_command(fastboot_cmd + ["reboot"]): sys.exit(1)

    print("\nAll done!")
    input("Press Enter to exit...")

if __name__ == "__main__":
    main()