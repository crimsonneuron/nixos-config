{lib, inputs, config,pkgs, osConfig, ...}:

let 
  isLaptop = osConfig.networking.hostName == "lsla";
  wallpaperPath = if isLaptop then "rocket_desert_wallpaper.png" else "nasa_mirror_1920x1080.png";
in
{
  home.packages = with pkgs; [
    grim
    slurp
    brightnessctl
  ];
  programs.niri.settings = {
    input = {
      keyboard.xkb = {
        layout = "us, gr";
        options = "grp:alt_caps_toggle";
      };
    };
    switch-events = {
      lid-close.action.spawn = ["noctalia-shell" "ipc" "call" "lockScreen" "lock"];
    };
    window-rules = [
      {
        matches = [];
        clip-to-geometry = true;
        geometry-corner-radius = {
          bottom-right = 20.0;
          bottom-left = 20.0;
          top-right =20.0;
          top-left = 20.0;
        };
      }
    ];
    outputs = if isLaptop then {
    } else {
      "DP-2" = {
        scale = 2;
        position = {
          x = 0;
          y =0;
        };
        focus-at-startup = true;
      };
      "HDMI-A-2" = {
        scale = 1;
        position = {
          x=1920;
          y=0;
        };
      };
    };
    layout = {
      gaps = 16;
      center-focused-column = "never";
      preset-column-widths =  [
        {proportion = 0.33;}
        {proportion = 0.5;}
        {proportion = 0.66;}
      ];
      default-column-width = {proportion = 0.5;};
      focus-ring = {
        enable =true;
        width = 4;
        active.gradient = {
          from = "#80c8ff";
          to = "#c7ff7f";
          angle = 45;
        };
      };
    };
    overview = { zoom = 0.33;};
    spawn-at-startup = [
      {argv = ["noctalia-shell"];}
    ];
    hotkey-overlay.skip-at-startup = true;

     binds = with config.lib.niri.actions;  {
      "Mod+Shift+Slash".action = show-hotkey-overlay;
      "Mod+Return".action = spawn "kitty";
      "Mod+B".action = spawn "zen-beta";
      "Mod+D".action = spawn "vesktop";
      "Alt+Space".action = spawn "sh" "-c" "noctalia-shell ipc call launcher toggle";
      "Mod+Pause".action = spawn "sh" "-c" "/home/crimson/nixos/scripts/bash/poweroff.sh";
      "Super+Alt+L".action = spawn "sh" "-c" "hyprlock";
      "Super+Alt+S".action = spawn "sh" "-c" "pkill orca || exec orca";

      # Audio controls
      "XF86AudioRaiseVolume".action = spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1+";
      "XF86AudioLowerVolume".action = spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1-";
      "XF86AudioMute".action = spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle";
      "XF86AudioMicMute".action = spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle";
      "XF86AudioPlay".action = spawn "playerctl" "play-pause";
      "XF86AudioNext".action = spawn "playerctl" "next";
      "XF86AudioPrev".action = spawn "playerctl" "previous";

      # Brightness controls
      "XF86MonBrightnessUp".action = spawn "brightnessctl" "--class=backlight" "set" "+10%";
      "XF86MonBrightnessDown".action = spawn "brightnessctl" "--class=backlight" "set" "10%-";

      # Window and workspace management
      "Mod+O".action = toggle-overview;
      "Mod+Q".action = close-window;

      # Focus navigation
      "Mod+Left".action = focus-column-left;
      "Mod+Down".action = focus-window-down;
      "Mod+Up".action = focus-window-up;
      "Mod+Right".action = focus-column-right;
      "Mod+H".action = focus-column-left;
      "Mod+J".action = focus-window-down;
      "Mod+K".action = focus-window-up;
      "Mod+L".action = focus-column-right;

      # Move windows/columns
      "Mod+Ctrl+Left".action = move-column-left;
      "Mod+Ctrl+Down".action = move-window-down;
      "Mod+Ctrl+Up".action = move-window-up;
      "Mod+Ctrl+Right".action = move-column-right;
      "Mod+Ctrl+H".action = move-column-left;
      "Mod+Ctrl+J".action = move-window-down;
      "Mod+Ctrl+K".action = move-window-up;
      "Mod+Ctrl+L".action = move-column-right;

      # Column first/last
      "Mod+Home".action = focus-column-first;
      "Mod+End".action = focus-column-last;
      "Mod+Ctrl+Home".action = move-column-to-first;
      "Mod+Ctrl+End".action = move-column-to-last;

      # Monitor focus
      "Mod+Shift+Left".action = focus-monitor-left;
      "Mod+Shift+Down".action = focus-monitor-down;
      "Mod+Shift+Up".action = focus-monitor-up;
      "Mod+Shift+Right".action = focus-monitor-right;
      "Mod+Shift+H".action = focus-monitor-left;
      "Mod+Shift+J".action = focus-monitor-down;
      "Mod+Shift+K".action = focus-monitor-up;
      "Mod+Shift+L".action = focus-monitor-right;

      # Move column to monitor
      "Mod+Shift+Ctrl+Left".action = move-column-to-monitor-left;
      "Mod+Shift+Ctrl+Down".action = move-column-to-monitor-down;
      "Mod+Shift+Ctrl+Up".action = move-column-to-monitor-up;
      "Mod+Shift+Ctrl+Right".action = move-column-to-monitor-right;
      "Mod+Shift+Ctrl+H".action = move-column-to-monitor-left;
      "Mod+Shift+Ctrl+J".action = move-column-to-monitor-down;
      "Mod+Shift+Ctrl+K".action = move-column-to-monitor-up;
      "Mod+Shift+Ctrl+L".action = move-column-to-monitor-right;

      # Move workspace to monitor
      "Mod+Shift+Alt+Left".action = move-workspace-to-monitor-left;
      "Mod+Shift+Alt+Right".action = move-workspace-to-monitor-right;

      # Workspace focus
      "Mod+Page_Down".action = focus-workspace-down;
      "Mod+Page_Up".action = focus-workspace-up;
      "Mod+U".action = focus-workspace-down;
      "Mod+I".action = focus-workspace-up;

      # Move column to workspace
      "Mod+Ctrl+Page_Down".action = move-column-to-workspace-down;
      "Mod+Ctrl+Page_Up".action = move-column-to-workspace-up;
      "Mod+Ctrl+U".action = move-column-to-workspace-down;
      "Mod+Ctrl+I".action = move-column-to-workspace-up;

      # Move workspace
      "Mod+Shift+Page_Down".action = move-workspace-down;
      "Mod+Shift+Page_Up".action = move-workspace-up;
      "Mod+Shift+U".action = move-workspace-down;
      "Mod+Shift+I".action = move-workspace-up;

      # Mouse wheel scrolling
      "Mod+WheelScrollDown".action = focus-workspace-down;
      "Mod+WheelScrollUp".action = focus-workspace-up;
      "Mod+Ctrl+WheelScrollDown".action = move-column-to-workspace-down;
      "Mod+Ctrl+WheelScrollUp".action = move-column-to-workspace-up;
      "Mod+WheelScrollRight".action = focus-column-right;
      "Mod+WheelScrollLeft".action = focus-column-left;
      "Mod+Ctrl+WheelScrollRight".action = move-column-right;
      "Mod+Ctrl+WheelScrollLeft".action = move-column-left;
      "Mod+Shift+WheelScrollDown".action = focus-column-right;
      "Mod+Shift+WheelScrollUp".action = focus-column-left;
      "Mod+Ctrl+Shift+WheelScrollDown".action = move-column-right;
      "Mod+Ctrl+Shift+WheelScrollUp".action = move-column-left;

      # Workspace numbers
      "Mod+1".action = focus-workspace 1;
      "Mod+2".action = focus-workspace 2;
      "Mod+3".action = focus-workspace 3;
      "Mod+4".action = focus-workspace 4;
      "Mod+5".action = focus-workspace 5;
      "Mod+6".action = focus-workspace 6;
      "Mod+7".action = focus-workspace 7;
      "Mod+8".action = focus-workspace 8;
      "Mod+9".action = focus-workspace 9;

      "Mod+BracketLeft".action = consume-or-expel-window-left;
      "Mod+BracketRight".action = consume-or-expel-window-right;
      "Mod+Comma".action = consume-window-into-column;
      "Mod+Period".action = expel-window-from-column;

      # Column and window sizing
      "Mod+R".action = switch-preset-column-width;
      "Mod+Shift+R".action = switch-preset-window-height;
      "Mod+Ctrl+R".action = reset-window-height;
      "Mod+F".action = maximize-column;
      "Mod+Shift+F".action = fullscreen-window;
      "Mod+Ctrl+F".action = expand-column-to-available-width;
      "Mod+C".action = center-column;
      "Mod+Ctrl+C".action = center-visible-columns;
      "Mod+Minus".action = set-column-width "-10%";
      "Mod+Equal".action = set-column-width "+10%";
      "Mod+Shift+Minus".action = set-window-height "-10%";
      "Mod+Shift+Equal".action = set-window-height "+10%";

      # Floating and tabbed
      "Mod+V".action = toggle-window-floating;
      "Mod+Shift+V".action = switch-focus-between-floating-and-tiling;
      "Mod+W".action = toggle-column-tabbed-display;

      # Screenshots
      "Print".action = spawn "sh" "-c" "grim -g \"$(slurp)\" - | wl-copy";
      #"Ctrl+Print".action = screenshot-screen;
      #"Alt+Print".action = screenshot-window;

      # System
      "Mod+Escape".action = toggle-keyboard-shortcuts-inhibit;
      "Mod+Shift+E".action = quit;
      "Ctrl+Alt+Delete".action = quit;
      "Mod+Shift+P".action = power-off-monitors;
      };

    debug = {
      honor-xdg-activation-with-invalid-serial = [];
    };
  };
}

