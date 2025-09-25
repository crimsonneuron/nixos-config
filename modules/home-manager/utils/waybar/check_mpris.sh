#!/usr/bin/env bash

# Check for active MPRIS players
check_players() {
    # Try multiple methods to detect active players
    if playerctl status 2>/dev/null | grep -q -v "No players found"; then
        return 0  # Players found
    fi
    
    return 1  # No players found
}

# Main execution
if check_players; then
    # Players exist, output empty JSON to hide this module
    echo '{"text":"","tooltip":""}'
else
    # No players found, show default text
    echo '{"text":"🔇 No media playing","tooltip":"No active media players","class":"no-media"}'
fi
