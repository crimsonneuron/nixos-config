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
        
        # Get player name safely
        try:
            trackid = subprocess.check_output(
                ["playerctl", "metadata", "mpris:trackid"], 
                stderr=subprocess.DEVNULL
            ).decode().strip()
            
            # Extract player name from trackid (e.g., org.mpris.MediaPlayer2.spotify)
            parts = trackid.split(".")
            player = parts[-2] if len(parts) >= 2 else "unknown"
        except:
            # Fallback: get player name directly
            try:
                player = subprocess.check_output(
                    ["playerctl", "-l"], 
                    stderr=subprocess.DEVNULL
                ).decode().strip().split('\n')[0]
            except:
                player = "unknown"
        
        # Format output
        if status == "Playing":
            icon = "▶"
        elif status == "Paused":
            icon = "⏸"
        else:
            icon = "⏹"
        
        # Player-specific icons
        player_icons = {
            "spotify": "",
            "youtube-music-desktop-app": "",
            "firefox": "🌍",
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
            text=False  # Read as bytes for raw output
        )
        
        # Save PID
        CAVA_PID_FILE.write_text(str(process.pid))
        
        # Convert raw bytes to safe Unicode bars
        bar_chars = ["▁", "▂", "▃", "▄", "▅"]
        
        while True:
            if process.poll() is not None:
                break
                
            try:
                # Read raw bytes in smaller chunks for faster response
                raw_data = process.stdout.read(12)
                if not raw_data:
                    time.sleep(0.01)  # Small delay to prevent CPU spinning
                    continue
                
                # Skip if we get invalid data (all zeros or all max values)
                if all(b == 0 for b in raw_data) or all(b >= 250 for b in raw_data):
                    continue
                
                # Convert bytes to bar visualization using safe Unicode
                bars = ""
                for byte in raw_data:
                    # More aggressive clamping and scaling
                    scaled_byte = min(byte * 8 // 256, 4)  # Scale 0-255 to 0-7
                    bars += bar_chars[scaled_byte]
                
                output = {
                    "text": f"♪ {bars}",
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
    while True:
        current_state = get_state()
        
        if current_state == "cava":
            start_cava()
            # If cava exits, switch back to mpris
            set_state("mpris")
        else:
            # MPRIS mode - output and continue
            output = get_mpris_info()
            print(json.dumps(output), flush=True)
            time.sleep(1)

if __name__ == "__main__":
    main()
