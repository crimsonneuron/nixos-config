#!/usr/bin/env python3
import subprocess
import getpass
import os
import sys
import time

# --- CONFIGURATION SECTION ---
# The full path to the encrypted file on your USB drive
# Example: "/run/media/myuser/MY_USB_NAME/vault.hc"
ENCRYPTED_CONTAINER_PATH = "/run/media/crimson/SPHINCS/encryVault.vc"

# The directory where you want it mounted (Obsidian looks here)
MOUNT_POINT = "/run/media/veracrypt1"

# The name of the item in Bitwarden that holds the USB encryption password
BW_ITEM_NAME = "SPHINCS Drive"

# Command to launch Obsidian (NixOS usually puts binaries in path)
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

def main():
    print("--- 🔓 Obsidian Vault Autoloader ---")

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

    # 3. Gather Credentials
    print("\nPlease enter credentials (input is hidden):")
    try:
        bw_master_pass = getpass.getpass("🔑 Bitwarden Master Password: ")
        sudo_pass = getpass.getpass("🛡️  Sudo Password: ")
    except KeyboardInterrupt:
        print("\nOperation cancelled.")
        sys.exit(0)

    print("\n[1/4] Unlocking Bitwarden Vault...")
    
    # Unlock Bitwarden and get Session Key
    # We pass the existing environment so we don't lose PATH, but add nothing else yet.
    bw_env = os.environ.copy()
    
    # 'bw unlock --raw' returns just the session key
    unlock_res = run_command(f"bw unlock '{bw_master_pass}' --raw")
    
    if unlock_res.returncode != 0:
        print("❌ Failed to unlock Bitwarden. Check your master password.")
        print(f"Debug: {unlock_res.stderr}")
        sys.exit(1)
        
    session_key = unlock_res.stdout.strip()
    bw_env["BW_SESSION"] = session_key

    # Retrieve the USB Password
    print(f"[2/4] Retrieving password for '{BW_ITEM_NAME}'...")
    get_pass_res = run_command(f"bw get password '{BW_ITEM_NAME}'", env=bw_env)
    
    if get_pass_res.returncode != 0:
        print(f"❌ Failed to retrieve item '{BW_ITEM_NAME}'. Check the name.")
        sys.exit(1)
        
    usb_password = get_pass_res.stdout.strip()

    # 4. Mount VeraCrypt
    print(f"[3/4] Mounting VeraCrypt volume to {MOUNT_POINT}...")
    
    # We verify sudo first to avoid awkward timeouts later
    sudo_check = run_command(f"sudo -S -v", input_text=f"{sudo_pass}\n")
    if sudo_check.returncode != 0:
        print("❌ Sudo authentication failed.")
        sys.exit(1)

    # Construct VeraCrypt command
    # -t: text mode
    # --pim 0: assumes no PIM
    # -k "": assumes no keyfile
    # --protect-hidden no: standard option to avoid questions
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

    # 5. Launch Obsidian
    print("[4/4] Launching Obsidian...")
    # Using Popen to detach the process so closing the terminal doesn't kill Obsidian
    subprocess.Popen(
        f"{OBSIDIAN_CMD} > /dev/null 2>&1 &", 
        shell=True, 
        start_new_session=True
    )
    
    # Give a brief pause to see the success message
    time.sleep(1.5)

if __name__ == "__main__":
    main()
