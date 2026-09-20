#!/usr/bin/env bash
#
# vault — open/close the VeraCrypt notes vault, with automatic backups.
#
# Usage:
#   vault             toggle: open if closed, offer to close if open
#   vault open
#   vault close
#   vault status
#   vault backup      snapshot now (vault must be open)
#   vault init-backup one-time setup of the git repo + restic repository
#   vault restore     print instructions for getting data back out
#
# Backups run automatically on open and on close. Two layers:
#   git    — commits inside the vault, so history lives encrypted alongside
#            the notes and gets included in the restic snapshots below.
#   restic — encrypted, deduplicated snapshots to RESTIC_REPO, off the stick.
#
set -euo pipefail

VAULT="/run/media/crimson/SPHINCS/encryVault.vc"
STICK="$(dirname "$VAULT")"
MOUNT="/run/media/veracrypt1"

RESTIC_REPO="${HOME}/Backups/vault-repo"
RESTIC_PW_FILE="${HOME}/.config/vault/restic-password"
STATE_DIR="${HOME}/.local/state/vault"
PRUNE_INTERVAL=$((7 * 24 * 3600))

# Retention for restic. Plenty for text; adjust to taste.
KEEP=(--keep-last 10 --keep-daily 7 --keep-weekly 8 --keep-monthly 12)

# If the vault's *interior* filesystem is FAT or exFAT, uncomment this so the
# files aren't root-owned. Leave empty for ext4, which stores ownership itself.
FS_OPTS=""
#FS_OPTS="uid=$(id -u),gid=$(id -g),umask=022"

# --- output helpers ----------------------------------------------------------

if [[ -t 1 ]]; then
  BOLD=$'\e[1m'; RED=$'\e[31m'; YEL=$'\e[33m'; GRN=$'\e[32m'; DIM=$'\e[2m'; OFF=$'\e[0m'
else
  BOLD=""; RED=""; YEL=""; GRN=""; DIM=""; OFF=""
fi

info() { printf '%s\n' "$*"; }
dim()  { printf '%s%s%s\n' "$DIM" "$*" "$OFF"; }
ok()   { printf '%s%s%s\n' "$GRN" "$*" "$OFF"; }
warn() { printf '%s%s%s\n' "$YEL" "$*" "$OFF" >&2; }
die()  { printf '%s%s%s\n' "$RED$BOLD" "$*" "$OFF" >&2; exit 1; }

need() { command -v "$1" >/dev/null 2>&1 || die "Missing required command: $1"; }
have() { command -v "$1" >/dev/null 2>&1; }

# When launched from the application picker, hold the window open so errors
# are readable instead of flashing past.
if [[ -n "${VAULT_FROM_LAUNCHER:-}" ]]; then
  trap 'printf "\n"; dim "Press Enter to close."; read -r _ || true' EXIT
fi

# --- state -------------------------------------------------------------------

is_open() { mountpoint -q "$MOUNT"; }

mapped_volumes() { compgen -G "/dev/mapper/veracrypt*" >/dev/null 2>&1; }

check_stick() {
  if [[ ! -d "$STICK" ]]; then
    die "Can't see $STICK — the USB stick isn't plugged in, or it didn't mount.

Check with:  lsblk -o NAME,SIZE,FSTYPE,LABEL,MOUNTPOINT"
  fi
  if [[ ! -f "$VAULT" ]]; then
    warn "The stick is mounted at $STICK but there's no $(basename "$VAULT") on it."
    info "Contents:"
    ls -lh "$STICK" || true
    exit 1
  fi
  [[ -r "$VAULT" ]] || die "$VAULT exists but isn't readable by $(id -un)."
}

# --- backups -----------------------------------------------------------------

git_snapshot() {
  have git || { warn "git not installed — skipping git snapshot."; return 0; }

  if [[ ! -d "$MOUNT/.git" ]]; then
    warn "No git repo in the vault yet. Run:  vault init-backup"
    return 0
  fi

  git -C "$MOUNT" add -A || { warn "git add failed — skipping commit."; return 0; }

  if git -C "$MOUNT" diff --cached --quiet; then
    dim "git: no changes"
    return 0
  fi

  local n
  n="$(git -C "$MOUNT" diff --cached --numstat | wc -l)"
  if git -C "$MOUNT" commit -q -m "auto: $(date '+%Y-%m-%d %H:%M')"; then
    ok "git: committed $n changed file(s)"
  else
    warn "git commit failed."
  fi
}

restic_env_ok() {
  have restic || { warn "restic not installed — skipping encrypted snapshot."; return 1; }
  if [[ ! -f "$RESTIC_PW_FILE" ]]; then
    warn "No restic password file at $RESTIC_PW_FILE. Run:  vault init-backup"
    return 1
  fi
  if [[ ! -d "$RESTIC_REPO" ]]; then
    warn "No restic repository at $RESTIC_REPO. Run:  vault init-backup"
    return 1
  fi
  export RESTIC_REPOSITORY="$RESTIC_REPO"
  export RESTIC_PASSWORD_FILE="$RESTIC_PW_FILE"
}

prune_if_due() {
  local stamp="$STATE_DIR/last-prune" now age
  mkdir -p "$STATE_DIR"
  now="$(date +%s)"
  if [[ -f "$stamp" ]]; then
    age=$(( now - $(stat -c %Y "$stamp") ))
    (( age < PRUNE_INTERVAL )) && return 0
  fi
  dim "restic: pruning old snapshots..."
  if restic forget "${KEEP[@]}" --prune --quiet; then
    touch "$stamp"
  else
    warn "restic prune failed (harmless; snapshots are intact)."
  fi
}

restic_snapshot() {
  restic_env_ok || return 0

  if restic backup "$MOUNT" \
       --tag vault \
       --exclude 'lost+found' \
       --exclude '.Trash-*' \
       --quiet; then
    ok "restic: snapshot saved"
    prune_if_due
  else
    warn "restic backup failed — your notes are fine, but this snapshot didn't save."
  fi
}

run_backups() {
  local label="${1:-}"
  [[ -n "$label" ]] && dim "--- backup ($label) ---"
  # Non-fatal: never block access to notes because a backup hiccuped.
  git_snapshot || true
  restic_snapshot || true
}

do_init_backup() {
  is_open || die "Open the vault first, then run this:  vault open"
  need git
  need restic

  if [[ ! -d "$MOUNT/.git" ]]; then
    git -C "$MOUNT" init -q -b main
    git -C "$MOUNT" config user.name "$(id -un)"
    git -C "$MOUNT" config user.email "$(id -un)@$(hostname)"
    printf 'lost+found/\n.Trash-*/\n' > "$MOUNT/.gitignore"
    ok "Created git repo inside the vault."
  else
    dim "git repo already present."
  fi

  mkdir -p "$(dirname "$RESTIC_PW_FILE")" "$HOME/Backups" "$STATE_DIR"

  if [[ ! -f "$RESTIC_PW_FILE" ]]; then
    info "Choose a password for the restic backup repository."
    info "Write it down somewhere safe — without it the backups are unrecoverable."
    local p1 p2
    read -rsp "Restic password: " p1; echo
    read -rsp "Again: " p2; echo
    [[ "$p1" == "$p2" ]] || die "Passwords didn't match."
    [[ -n "$p1" ]] || die "Empty password."
    (umask 077; printf '%s' "$p1" > "$RESTIC_PW_FILE")
    unset p1 p2
    ok "Saved password to $RESTIC_PW_FILE (mode 600)."
  else
    dim "restic password file already present."
  fi

  export RESTIC_REPOSITORY="$RESTIC_REPO"
  export RESTIC_PASSWORD_FILE="$RESTIC_PW_FILE"

  if [[ ! -d "$RESTIC_REPO" ]]; then
    restic init || die "restic init failed."
    ok "Initialised restic repository at $RESTIC_REPO"
  else
    dim "restic repository already exists."
  fi

  run_backups "initial"
  ok "Backups are set up. They'll now run automatically on open and close."
}

do_restore() {
  cat <<EOF
Recovering notes
================

From git history (vault must be open):
  git -C $MOUNT log --oneline
  git -C $MOUNT show <commit>:path/to/note.md
  git -C $MOUNT restore --source=<commit> -- path/to/note.md

From restic (works even if the stick is gone):
  export RESTIC_REPOSITORY=$RESTIC_REPO
  export RESTIC_PASSWORD_FILE=$RESTIC_PW_FILE
  restic snapshots
  restic restore latest --target /tmp/vault-restore
  restic mount /tmp/browse      # browse all snapshots as a filesystem

A restic snapshot includes the vault's .git directory, so restoring one
gives you the full history back too.
EOF
}

# --- open / close ------------------------------------------------------------

do_open() {
  if is_open; then
    ok "Already open at $MOUNT"
    return 0
  fi

  check_stick

  if mapped_volumes; then
    warn "A VeraCrypt volume is mapped but not mounted — a previous session may
not have closed cleanly. Inspect with:  sudo veracrypt --text --list"
  fi

  info "Administrator access is needed to mount the volume."
  sudo -v

  sudo mkdir -p "$MOUNT"

  local -a args=(
    --text --mount "$VAULT" "$MOUNT"
    --pim 0 --keyfiles "" --protect-hidden no
  )
  [[ -n "$FS_OPTS" ]] && args+=(--fs-options "$FS_OPTS")

  info "Enter the vault password:"
  sudo veracrypt "${args[@]}" || die "Mount failed."

  is_open || die "VeraCrypt reported success but nothing is mounted at $MOUNT"

  local fstype used avail
  fstype="$(findmnt -no FSTYPE "$MOUNT")"
  read -r used avail < <(df -h --output=used,avail "$MOUNT" | tail -1)
  ok "Open at $MOUNT  ($fstype, $used used, $avail free)"

  [[ -w "$MOUNT" ]] || warn "Note: $MOUNT isn't writable by you. If the interior is
FAT/exFAT, uncomment the FS_OPTS line near the top of this script."

  # Catches anything left uncommitted by a session that ended badly.
  run_backups "on open"
}

do_close() {
  if ! is_open; then
    info "Nothing mounted at $MOUNT."
    mapped_volumes && warn "A stale mapping exists — try: sudo veracrypt --text --dismount"
    return 0
  fi

  run_backups "on close"

  sync

  if ! sudo veracrypt --text --dismount "$MOUNT"; then
    warn "Dismount failed — something is probably still using the vault."
    if have fuser; then
      info "Processes holding it open:"
      sudo fuser -vm "$MOUNT" || true
    else
      info "Install psmisc and run:  sudo fuser -vm $MOUNT"
    fi
    info "Also check that no shell's working directory is inside $MOUNT."
    exit 1
  fi

  is_open && die "veracrypt exited 0 but $MOUNT is still mounted"
  ok "Closed cleanly."
}

do_status() {
  if is_open; then
    findmnt -o TARGET,SOURCE,FSTYPE,OPTIONS "$MOUNT"
    if [[ -d "$MOUNT/.git" ]] && have git; then
      dim "git: $(git -C "$MOUNT" rev-list --count HEAD 2>/dev/null || echo 0) commit(s), \
$(git -C "$MOUNT" status --porcelain | wc -l) uncommitted change(s)"
    fi
  else
    info "Closed."
    if [[ -f "$VAULT" ]]; then
      info "Vault file present at $VAULT"
    else
      warn "Vault file NOT visible (stick unplugged?)"
    fi
    mapped_volumes && warn "Stale VeraCrypt mapping present."
  fi

  if restic_env_ok 2>/dev/null; then
    dim "restic repository: $RESTIC_REPO"
    restic snapshots --latest 3 || true
  fi
}

# --- main --------------------------------------------------------------------

need veracrypt
need mountpoint
need findmnt

case "${1:-toggle}" in
  open)        do_open ;;
  close)       do_close ;;
  backup)      is_open || die "Open the vault first."; run_backups "manual" ;;
  init-backup) do_init_backup ;;
  restore)     do_restore ;;
  status)      do_status ;;
  toggle)
    if is_open; then
      ok "The vault is currently open at $MOUNT."
      read -rp "Close it? [y/N] " reply
      case "$reply" in
        [yY]|[yY][eE][sS]) do_close ;;
        *) info "Left open." ;;
      esac
    else
      do_open
    fi
    ;;
  *) die "Usage: vault [open|close|backup|init-backup|restore|status]" ;;
esac
