#!/usr/bin/env bash

#!/usr/bin/env bash

# Get the actual user's home directory even when run with sudo
if [ -n "$SUDO_USER" ]; then
    USER_HOME=$(eval echo "~$SUDO_USER")
else
    USER_HOME="$HOME"
fi

NIXOS_DIR="$USER_HOME/nixos"

# Change to nixos directory
cd "$NIXOS_DIR"

# Run git commands as the actual user, not root
if [ -n "$SUDO_USER" ]; then
    echo "Debug: Running git commands as user $SUDO_USER"
    sudo -u "$SUDO_USER" git add .
    sudo -u "$SUDO_USER" git status --porcelain
    
    CHANGES_COMMITTED=false
    echo "Debug: Attempting to commit..."
    if sudo -u "$SUDO_USER" git commit -m "NixOS config update - $(date '+%Y-%m-%d %H:%M:%S')"; then
        echo "Committed changes to git"
        CHANGES_COMMITTED=true
    else
        echo "No changes to commit"
    fi
    
    # Push to GitHub only if there were changes
    if [ "$CHANGES_COMMITTED" = true ]; then
        sudo -u "$SUDO_USER" git push
        echo "Pushed to GitHub"
    else
        echo "No changes to push"
    fi
else
    # Running as regular user
    echo "Debug: Adding changes to git..."
    git add .
    git status --porcelain
    
    CHANGES_COMMITTED=false
    echo "Debug: Attempting to commit..."
    if git commit -m "NixOS config update - $(date '+%Y-%m-%d %H:%M:%S')"; then
        echo "Committed changes to git"
        CHANGES_COMMITTED=true
    else
        echo "No changes to commit"
    fi
    
    # Push to GitHub only if there were changes
    if [ "$CHANGES_COMMITTED" = true ]; then
        git push
        echo "Pushed to GitHub"
    else
        echo "No changes to push"
    fi
fi

# Determine flake target based on hostname
HOSTNAME=$(hostname)
if [[ "$HOSTNAME" == "nixos-laptop" ]]; then
    FLAKE_TARGET=".#laptop"
elif [[ "$HOSTNAME" == "nixos-desktop" ]]; then
    FLAKE_TARGET=".#desktop"
else
    FLAKE_TARGET="."
fi

# Rebuild NixOS from flake (this needs sudo, but git commands above don't)
echo "Rebuilding NixOS with target: $FLAKE_TARGET"
sudo nixos-rebuild switch --flake "$FLAKE_TARGET"
echo "NixOS rebuild complete!"
