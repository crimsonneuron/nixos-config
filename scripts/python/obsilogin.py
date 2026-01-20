#!/usr/bin/env python3
import subprocess
import getpass
import os
import sys
import time
import shutil

# --- CONFIGURATION SECTION ---
# 1. The full path to the encrypted file on your USB drive
# Example: "/run/media/myuser/MY_USB_NAME/vault.hc"
ENCRYPTED_CONTAINER_PATH = "/run/media/crimson/SPHINCS/encryVault.vc"

# 2. The directory where you want it mounted (Obsidian looks here)
MOUNT_POINT = "/run/media/veracrypt1"

# 3. Where to store the backups (Local disk is best)
# The script will create this folder if it doesn't exist.
BACKUP_DIR = "/home/crimson/Backups/ObsidianVault"
# Number of backups to keep (3 is a safe balance)
BACKUP_RETENTION = 3

# 4. The name of the item in Bitwarden that holds the USB encryption password
BW_ITEM_NAME = "SPHINCS Drive"

# 5. Command to launch Obsidian
OBSIDIAN_CMD = "obsidian"
# -----------------------------

def run_command(command, input_text=None, env=None, capture_output=True):
    """Helper to run shell commands efficiently."""
    try:
        result = subprocess.run(
            command,
            input=input_text,
            capture_output=capture_output,
            text=True,
            shell=True,
            env=env
        )
        return result
    except Exception as e:
        print(f"Error executing command: {e}")
        return None

def perform_rotation_backup(source_file, backup_dir, retention):
    """
    Rotates backups (file.1, file.2, file.3) and copies the new one.
    """
    filename = os.path.basename(source_file)
    
    if not os.path.exists(backup_dir):
        try:
            os.makedirs(backup_dir)
        except OSError as e:
            print(f"❌ Could not create backup directory: {e}")
            return False

    print(f"    Rotation strategy: Keeping last {retention} copies.")

    # 1. Delete the oldest backup if it exists
    oldest_backup = os.path.join(backup_dir, f"{filename}.{retention}")
    if os.path.exists(oldest_backup):
        os.remove(oldest_backup)

    # 2. Shift existing backups down (e.g., .2 -> .3, .1 -> .2)
    # We loop backwards from retention-1 down to 1
    for i in range(retention - 1, 0, -1):
        current = os.path.join(backup_dir, f"{filename}.{i}")
        next_slot = os.path.join(backup_dir, f"{filename}.{i+1}")
        
        if os.path.exists(current):
            # Use move/rename to shift
            try:
                os.rename(current, next_slot)
            except OSError as e:
                print(f"    ⚠️ Warning: Failed to rotate backup {i} to {i+1}: {e}")

    # 3. Copy source to .1 (The newest backup)
    new_backup_path = os.path.join(backup_dir, f"{filename}.1")
    print(f"    Copying current drive to: {new_backup_path}...")
    try:
        shutil.copy2(source_file, new_backup_path)
        return True
    except IOError as e:
        print(f"❌ Copy failed: {e}")
        return False

def main():
    print("--- 🔓 Obsidian Vault Autoloader & Backup ---")

    # 1. Pre-flight Check: Is the USB plugged in?
    if not os.path.exists(ENCRYPTED_CONTAINER_PATH):
        print(f"\n[!] Error: Encrypted file not found at: {ENCRYPTED_CONTAINER_PATH}")
        print("    Please plug in your USB drive and try again.")
        sys.exit(1)
    
    # 2. Check if already mounted
    if os.path.ismount(MOUNT_POINT):
        print(f"\n[!] Drive appears to be already mounted at {MOUNT_POINT}.")
        launch = input("    Launch Obsidian anyway? (y/n): ")
        if launch.lower() == 'y':
            subprocess.Popen(OBSIDIAN_CMD, shell=True)
        sys.exit(0)

    # 3. Gather Credentials (Do this first so we don't backup if user cancels)
    print("\nPlease enter credentials (input is hidden):")
    try:
        bw_master_pass = getpass.getpass("🔑 Bitwarden Master Password: ")
        sudo_pass = getpass.getpass("🛡️  Sudo Password: ")
    except KeyboardInterrupt:
        print("\nOperation cancelled.")
        sys.exit(0)

    # --- NEW STEP: BACKUP ---
    print(f"\n[1/5] Backing up encrypted container...")
    backup_success = perform_rotation_backup(ENCRYPTED_CONTAINER_PATH, BACKUP_DIR, BACKUP_RETENTION)
    
    if backup_success:
        print("✅ Backup successful.")
    else:
        print("⚠️ BACKUP FAILED.")
        cont = input("    Do you want to continue mounting without a fresh backup? (y/N): ")
        if cont.lower() != 'y':
            print("Aborting.")
            sys.exit(1)
    # ------------------------

    print("\n[2/5] Unlocking Bitwarden Vault...")
    bw_env = os.environ.copy()
    
    # Unlock Bitwarden
    unlock_res = run_command(f"bw unlock '{bw_master_pass}' --raw")
    if unlock_res.returncode != 0:
        print("❌ Failed to unlock Bitwarden. Check your master password.")
        sys.exit(1)
        
    session_key = unlock_res.stdout.strip()
    bw_env["BW_SESSION"] = session_key

    # Retrieve USB Password
    print(f"[3/5] Retrieving password for '{BW_ITEM_NAME}'...")
    get_pass_res = run_command(f"bw get password '{BW_ITEM_NAME}'", env=bw_env)
    if get_pass_res.returncode != 0:
        print(f"❌ Failed to retrieve item '{BW_ITEM_NAME}'. Check the name.")
        sys.exit(1)
        
    usb_password = get_pass_res.stdout.strip()

    # Mount VeraCrypt
    print(f"[4/5] Mounting VeraCrypt volume to {MOUNT_POINT}...")
    
    # Pre-validate sudo
    sudo_check = run_command(f"sudo -S -v", input_text=f"{sudo_pass}\n")
    if sudo_check.returncode != 0:
        print("❌ Sudo authentication failed.")
        sys.exit(1)

    vc_cmd = (
        f"sudo -S veracrypt -t --mount '{ENCRYPTED_CONTAINER_PATH}' '{MOUNT_POINT}' "
        f"--password '{usb_password}' --pim 0 -k '' --protect-hidden no"
    )

    vc_res = run_command(vc_cmd, input_text=f"{sudo_pass}\n")

    if vc_res.returncode != 0:
        print("❌ VeraCrypt failed to mount.")
        print(vc_res.stdout)
        print(vc_res.stderr)
        sys.exit(1)

    print("✅ Drive mounted successfully.")

    # Launch Obsidian
    print("[5/5] Launching Obsidian...")
    subprocess.Popen(
        f"{OBSIDIAN_CMD} > /dev/null 2>&1 &", 
        shell=True, 
        start_new_session=True
    )
    
    time.sleep(1.5)

if __name__ == "__main__":
    main()
