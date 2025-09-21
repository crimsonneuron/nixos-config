#!/usr/bin/env bash

# A script for a Waybar custom module that switches between MPRIS info and Cava audio visualizer.

# State file to store whether we are showing 'mpris' or 'cava'
STATE_FILE="/dev/shm/waybar_mpris_cava_state"

# Cava configuration file path
CAVA_CONFIG="$HOME/.config/cava/cava-waybar-config"

# --- Function to toggle state ---
toggle_state() {
    if [ "$(cat "$STATE_FILE")" = "mpris" ]; then
        echo "cava" > "$STATE_FILE"
    else
        echo "mpris" > "$STATE_FILE"
    fi
}

# --- Signal Handler ---
# We use SIGRTMIN+1 as it's a safe, unused signal.
trap "toggle_state && kill -9 $CHILD_PID" SIGRTMIN+1

# --- Initial State ---
# Set the initial state to 'mpris' if the state file doesn't exist
if [ ! -f "$STATE_FILE" ]; then
    echo "mpris" > "$STATE_FILE"
fi

# --- Main Loop ---
while true; do
    CURRENT_STATE=$(cat "$STATE_FILE")

    if [ "$CURRENT_STATE" = "cava" ]; then
        # Run Cava and format its output for Waybar's JSON format
        cava -p "$CAVA_CONFIG" | while read -r line; do
            echo "{\"text\": \"$line\", \"tooltip\": \"Audio Visualizer (Right-click to switch)\"}"
        done &
    else
        # Run playerctl to follow MPRIS changes and format for Waybar's JSON
        # This command will only output when the song/status changes.
        playerctl --follow metadata --format '{"text": " {{artist}} - {{title}}", "alt": "{{status}}", "tooltip": "{{playerName}}: {{title}}", "class": "{{status}}"}' &
    fi

    CHILD_PID=$!
    wait $CHILD_PID
done
