#!/usr/bin/env python3

import json
import subprocess
import signal
import sys
import os
import threading
import time
from pathlib import Path

STATE_FILE = Path.home() / ".cache" / "waybar-media-state"
CAVA_PID_FILE = Path.home() / ".cache" / "waybar-cava-pid"

def get_state():
    """Get current state (mpris or cava)"""
    try:
        return STATE_FILE.read_text().strip()
    except:
        return "mpris"

def set_state(state):
    """Set current state"""
    STATE_FILE.parent.mkdir(exist_ok=True)
    STATE_FILE.write_text(state)

def kill_cava():
    """Kill any running cava process for this script"""
    try:
        if CAVA_PID_FILE.exists():
            pid = int(CAVA_PID_FILE.read_text().strip())
            os.kill(pid, signal.SIGTERM)
            CAVA_PID_FILE.unlink()
    except:
        pass

def get_mpris_info():
    """Get MPRIS info using playerctl"""
    try:
        # Get player status
        status = subprocess.check_output(
            ["playerctl", "status"], 
            stderr=subprocess.DEVNULL
        ).decode().strip()
        
        # Get metadata
        artist = subprocess.check_output(
            ["playerctl", "metadata", "artist"], 
            stderr=subprocess.DEVNULL
        ).decode().strip()
        
        title = subprocess.check_output(
            ["playerctl", "metadata", "title"], 
            stderr=subprocess.DEVNULL
        ).decode().strip()
        
        player = subprocess.check_output(
            ["playerctl", "metadata", "mpris:trackid"], 
            stderr=subprocess.DEVNULL
        ).decode().strip().split(".")[-2] if subprocess.check_output(
            ["playerctl", "metadata", "mpris:trackid"], 
            stderr=subprocess.DEVNULL
        ).decode().strip() else "unknown"
        
        # Format output
        if status == "Playing":
            icon = "▶"
        elif status == "Paused":
            icon = "⏸"
        else:
            icon = "⏹"
        
        # Player-specific icons
        player_icons = {
            "spotify": "",
            "YoutubeMusic": "",
            "firefox": "",
            "chromium": "🌍"
        }
        
        player_icon = player_icons.get(player.lower(), "🎵")
        
        # Truncate long text
        display_text = f"{artist} - {title}" if artist and title else title or "No media"
        if len(display_text) > 40:
            display_text = display_text[:37] + "..."
            
        return {
            "text": f"{icon} {display_text}",
            "tooltip": f"{player_icon} {artist} - {title}\n{status}",
            "class": f"mpris {status.lower()}"
        }
        
    except subprocess.CalledProcessError:
        return {
            "text": "🎵 No media",
            "tooltip": "No active media player",
            "class": "mpris idle"
        }

def start_cava():
    """Start cava and return its output"""
    kill_cava()  # Kill any existing cava
    
    try:
        # Start cava process using default config
        process = subprocess.Popen(
            ["cava"],
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,
            text=True
        )
        
        # Save PID
        CAVA_PID_FILE.write_text(str(process.pid))
        
        # Read cava output - assuming your config outputs text characters
        while True:
            if process.poll() is not None:
                break
                
            try:
                # Read a line of output from cava
                line = process.stdout.readline()
                if not line:
                    break
                
                # Clean up the line and use it directly
                cava_output = line.strip()
                if cava_output:
                    output = {
                        "text": f"♪ {cava_output}",
                        "tooltip": "Audio Visualizer (Right-click for media info)",
                        "class": "cava active"
                    }
                    
                    print(json.dumps(output), flush=True)
                
            except Exception as e:
                break
                
    except FileNotFoundError:
        return {
            "text": "❌ CAVA not found",
            "tooltip": "Install CAVA to use audio visualization",
            "class": "cava error"
        }
    except Exception as e:
        return {
            "text": "❌ CAVA error",
            "tooltip": f"CAVA error: {str(e)}",
            "class": "cava error"
        }

def handle_signal(signum, frame):
    """Handle shutdown signals"""
    kill_cava()
    sys.exit(0)

def main():
    # Handle shutdown gracefully
    signal.signal(signal.SIGTERM, handle_signal)
    signal.signal(signal.SIGINT, handle_signal)
    
    # Check for toggle command
    if len(sys.argv) > 1 and sys.argv[1] == "toggle":
        current_state = get_state()
        new_state = "cava" if current_state == "mpris" else "mpris"
        set_state(new_state)
        kill_cava()  # Kill cava when switching away
        sys.exit(0)
    
    # Main loop
    current_state = get_state()
    
    if current_state == "cava":
        start_cava()
    else:
        # MPRIS mode - output once and exit (waybar will re-run)
        while True:
            output = get_mpris_info()
            print(json.dumps(output), flush=True)
            time.sleep(1)

if __name__ == "__main__":
    main()
