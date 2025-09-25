{pkgs,lib,osConfig, ...}:

let 
  hostname = osConfig.networking.hostName; 
  isLaptop = hostname == "lsla";
  baseRightModules = ["group/expand" "bluetooth" "network" ];
  allModules = baseRightModules ++ lib.optional isLaptop "battery";
in
{
  programs.cava.enable=true;
  programs.waybar = {
    enable=true;
     
     settings = {
      mainBar = {
        layer = "top";
        position = "top";
        reload_style_on_change = true;
        modules-left = ["custom/notification" "clock" "tray"];
        modules-center = ["mpris" "custom/no-media" "custom/distro" "cava"];
        modules-right = allModules; 
         #"custom/media-toggle" = {
             #format = "{}";
             #return-type = "json";
             #exec = "~/nixos/modules/home-manager/utils/waybar/control_script.py";
             #on-click = "playerctl play-pause";
             #on-click-right = "~/nixos/modules/home-manager/utils/waybar/control_script.py toggle";
             #on-click-middle = "playerctl next";
             #on-scroll-up = "playerctl volume 0.05+";
             #on-scroll-down = "playerctl volume 0.05-";
             #escape = true;
             #restart-interval = 0;
         #};

        "custom/notification" = {
          tooltip = false;
          format = "";
          on-click = "swaync-client -t -sw";
          escape = true;
        };
        "custom/no-media" = {
          exec = "~/nixos/modules/home-manager/utils/waybar/check_mpris.sh";
          interval = 1;
          return-type = "json";
          format = "{}";
          tooltip = false;
        };
        cava = {
          framerate = 30;
          autosens = 1;
          sensitivity = 100;
          bars = 14;
          lower_cutoff_freq = 50;
          higher_cutoff_freq = 10000;
          hide_on_silence = false;
          method = "pulse";
          source="auto";
          stereo = true;
          reverse = false;
          bar_delimiter = 0;
          monstercat = false;
          waves = false;
          noise_reduction = 0.77;
          input_delay = 2;
          format-icons =["▁" "▂" "▃" "▄" "▅"];
          actions = {
            on-click-right = "mode";
          };
        };
        "custom/distro" = {
          format = "";
          on-click ="neofetch";
        }; 
        mpris = {
          format = "{player_icon} {dynamic}";
          format-paused = "{status_icon} <i>{dynamic}</i>";
          format-stopped = "🎵 Nothing playing";
          tooltip=true;
          tooltip-format = "{player}: {title}";
          player-icons = {
            default = "🎵";
            YoutubeMusic = "󰗃";
            spotify = "󰓇";
            firefox = "";
          };
          status-icons= {
            paused = "";
            playing = "";
          };
          max-length = 20;
        };
        
        clock = {
          format = "{:%I:%M:%S %p} ";
          interval = 1;
          tooltip-format = "<tt>{calendar}</tt>";
          calendar = {
            format = {
              today = "<span color='#b0624e'><b>{}</b></span>";
            };
          };
          actions = {
            on-click-right = "shift_down";
            on-click = "shift_up";
          };
        };
        
        battery = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{icon} {capacity}";
          format-icons = ["󰁻" "󰁽" "󰂂"];
          format-charging = "󰂄 {capacity}";
        };
        
        network = {
          format-wifi = "";
          format-ethernet = "";
          format-disconnected = "";
          tooltip-format-disconnected = "Error";
          tooltip-format-wifi = "{essid} ({signalStrength}%) ï‡«";
          tooltip-format-ethernet = "{ifname}";
          on-click = "nm-connection-editor";
        };
        
        bluetooth = {
          format-on = "󰂯";
          format-off = "BT-off";
          format-disabled = "󰂲";
          format-connected-battery = "{device_battery_percentage}% 󰂯";
          format-alt = "{device_alias} 󰂯 ";
          tooltip-format = "{controller_alias}\t{controller_address}\n\n{num_connections} connected";
          tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{num_connections} connected\n\n{device_enumerate}";
          tooltip-format-enumerate-connected = "{device_alias}\n{device_address}";
          tooltip-format-enumerate-connected-battery = "{device_alias}\n{device_address}\n{device_battery_percentage}%";
          on-click-right = "blueman-manager";
        };
        
        "custom/expand" = {
          format = "";
          tooltip = false;
        };
        
        "custom/endpoint" = {
          format = "|";
          tooltip = false;
        };
        
        "group/expand" = {
          orientation = "horizontal";
          drawer = {
            transition-duration = 600;
            transition-to-left = true;
            click-to-reveal = true;
          };
          modules = ["custom/expand" "cpu" "memory" "temperature" "custom/endpoint"];
        };
        
        cpu = {
          format = "󰻠";
          tooltip = true;
        };
        
        memory = {
          format = "";
        };
        
        temperature = {
          critical-threshold = 80;
          format = "";
        };
        
        tray = {
          icon-size = 14;
          spacing = 10;
        };
      };
    };
    style = ''
          @import url('/home/crimson/.cache/wal/colors-waybar.css');

          * {
              font-size:15px;
              font-family: "CodeNewRoman Nerd Font Propo";
          }
          window#waybar{
              all:unset;
          }
          .modules-left {
              padding:7px;
              margin:10 0 5 10;
              border-radius:10px;
              background: alpha(@background,.6);
              box-shadow: 0px 0px 2px rgba(0, 0, 0, .6);
          }
          .modules-center {
              padding:7px;
              margin:10 0 5 0;
              border-radius:10px;
              background: alpha(@background,.6);
              box-shadow: 0px 0px 2px rgba(0, 0, 0, .6);
          }
          .modules-right {
              padding:7px;
              margin: 10 10 5 0;
              border-radius:10px;
              background: alpha(@background,.6);
              box-shadow: 0px 0px 2px rgba(0, 0, 0, .6);
          }
          tooltip {
              background:@background;
              color: @color7;
          }
          #clock:hover, #custom-pacman:hover, #custom-notification:hover,#bluetooth:hover,#network:hover,#battery:hover, #cpu:hover,#memory:hover,#temperature:hover{
              transition: all .3s ease;
              color:@color9;
          }
          #custom-notification {
              padding: 0px 5px;
              transition: all .3s ease;
              color:@color7;
          }
          #clock{
              padding: 0px 5px;
              color:@color7;
              transition: all .3s ease;
          }
          #custom-pacman{
              padding: 0px 5px;
              transition: all .3s ease;
              color:@color7;

          }
          #workspaces {
              padding: 0px 5px;
          }
          #workspaces button {
              all:unset;
              padding: 0px 5px;
              color: alpha(@color9,.4);
              transition: all .2s ease;
          }
          #workspaces button:hover {
              color:rgba(0,0,0,0);
              border: none;
              text-shadow: 0px 0px 1.5px rgba(0, 0, 0, .5);
              transition: all 1s ease;
          }
          #workspaces button.active {
              color: @color9;
              border: none;
              text-shadow: 0px 0px 2px rgba(0, 0, 0, .5);
          }
          #workspaces button.empty {
              color: rgba(0,0,0,0);
              border: none;
              text-shadow: 0px 0px 1.5px rgba(0, 0, 0, .2);
          }
          #workspaces button.empty:hover {
              color: rgba(0,0,0,0);
              border: none;
              text-shadow: 0px 0px 1.5px rgba(0, 0, 0, .5);
              transition: all 1s ease;
          }
          #workspaces button.empty.active {
              color: @color9;
              border: none;
              text-shadow: 0px 0px 2px rgba(0, 0, 0, .5);
          }
          #bluetooth{
              padding: 0px 5px;
              transition: all .3s ease;
              color:@color7;

          }
          #network{
              padding: 0px 5px;
              transition: all .3s ease;
              color:@color7;

          }
          #battery{
              padding: 0px 5px;
              transition: all .3s ease;
              color:@color7;


          }
          #battery.charging {
              color: #26A65B;
          }

          #battery.warning:not(.charging) {
              color: #ffbe61;
          }

          #battery.critical:not(.charging) {
              color: #f53c3c;
              animation-name: blink;
              animation-duration: 0.5s;
              animation-timing-function: linear;
              animation-iteration-count: infinite;
              animation-direction: alternate;
          }
          #group-expand{
              padding: 0px 5px;
              transition: all .3s ease; 
          }
          #custom-expand{
              padding: 0px 5px;
              color:alpha(@foreground,.2);
              text-shadow: 0px 0px 2px rgba(0, 0, 0, .7);
              transition: all .3s ease; 
          }
          #custom-expand:hover{
              color:rgba(255,255,255,.2);
              text-shadow: 0px 0px 2px rgba(255, 255, 255, .5);
          }
          #custom-colorpicker{
              padding: 0px 5px;
          }
          #cpu,#memory,#temperature{
              padding: 0px 5px;
              transition: all .3s ease; 
              color:@color7;

          }
          #custom-endpoint{
              color:transparent;
              text-shadow: 0px 0px 1.5px rgba(0, 0, 0, 1);

          }
          #tray{
              padding: 0px 5px;
              transition: all .3s ease; 

          }
          #tray menu * {
              padding: 0px 5px;
              transition: all .3s ease; 
          }

          #tray menu separator {
              padding: 0px 5px;
              transition: all .3s ease; 
          }
        '';

  };
}
