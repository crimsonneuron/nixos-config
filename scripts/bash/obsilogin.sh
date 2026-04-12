#!/usr/bin/env bash
# vc-open.sh — Mount a VeraCrypt volume from a USB drive, with rotating encrypted backups.
#
# CONFIGURE THESE:
ENCRYPTED_FILE="/run/media/crimson/SPHINCS/encryVault.vc"  # The VeraCrypt volume file — its presence also confirms the USB is plugged in
MOUNT_POINT="/run/media/veracrypt1"                     # Where to mount the decrypted volume
BACKUP_DIR="$HOME/Backups/ObsidianVault"                    # Where rotating backups are stored
MAX_BACKUPS=3                                      # Number of rotating backups to keep

# ── helpers ──────────────────────────────────────────────────────────────────

die() { echo "error: $*" >&2; exit 1; }

is_mounted() { veracrypt --text --list 2>/dev/null | grep -qF "$ENCRYPTED_FILE"; }

# ── preflight ────────────────────────────────────────────────────────────────

command -v veracrypt >/dev/null 2>&1 || die "veracrypt is not installed or not in PATH"

# ── already-mounted branch ────────────────────────────────────────────────────

if is_mounted; then
    echo "Volume is already mounted at $MOUNT_POINT."
    read -rp "Unmount it? [y/N] " CONFIRM
    if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
        read -rsp "sudo password: " SUDO_PASS; echo
        echo "$SUDO_PASS" | sudo -S veracrypt --text --dismount "$ENCRYPTED_FILE" 2>&1
        STATUS=$?
        SUDO_PASS=""; unset SUDO_PASS
        if [[ $STATUS -ne 0 ]]; then
            die "unmount failed (exit $STATUS) — is a file inside still open?"
        fi
        echo "Unmounted."
    else
        echo "Leaving volume mounted. Exiting."
    fi
    exit 0
fi

# ── drive check ──────────────────────────────────────────────────────────────

[[ -f "$ENCRYPTED_FILE" ]] || die "USB drive not detected or volume not found: $ENCRYPTED_FILE"

# ── rotating backup ───────────────────────────────────────────────────────────
# Keeps .1 (newest) through .N (oldest). Each run rotates everything down,
# dropping whatever was at slot N.

mkdir -p "$BACKUP_DIR"
BASENAME="$(basename "$ENCRYPTED_FILE")"

echo "Creating rotating backup..."

# Rotate: drop the oldest, shift everything down
for (( i = MAX_BACKUPS - 1; i >= 1; i-- )); do
    src="$BACKUP_DIR/$BASENAME.$i"
    dst="$BACKUP_DIR/$BASENAME.$((i + 1))"
    [[ -f "$src" ]] && mv "$src" "$dst"
done

# Copy current encrypted file into slot .1
cp "$ENCRYPTED_FILE" "$BACKUP_DIR/$BASENAME.1" \
    || die "backup failed — aborting before decryption"

echo "Backup saved → $BACKUP_DIR/$BASENAME.1"

# ── passwords ────────────────────────────────────────────────────────────────

read -rsp "VeraCrypt volume password: " VC_PASS; echo
read -rsp "sudo password: "             SUDO_PASS; echo

# ── mount ────────────────────────────────────────────────────────────────────

sudo -S mkdir -p "$MOUNT_POINT" <<< "$SUDO_PASS" 2>/dev/null \
    || die "could not create mount point $MOUNT_POINT (wrong sudo password?)"

echo "Mounting volume..."

echo "$SUDO_PASS" | sudo -S veracrypt \
    --text \
    --non-interactive \
    --password="$VC_PASS" \
    "$ENCRYPTED_FILE" "$MOUNT_POINT" 2>&1

STATUS=$?

# Scrub passwords from memory (best-effort in bash)
VC_PASS=""; SUDO_PASS=""
unset VC_PASS SUDO_PASS

if [[ $STATUS -ne 0 ]]; then
    die "veracrypt failed (exit $STATUS) — wrong password?"
fi

echo "Mounted at $MOUNT_POINT"

echo "Launching Obsidian..."
obsidian &
