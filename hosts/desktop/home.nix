{ config, pkgs,inputs,  ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "crimson";
  home.homeDirectory = "/home/crimson";
  nixpkgs.config.allowUnfree = true;

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.05"; # Please read the comment before changing.

  imports = [
    inputs.zen-browser.homeModules.beta
    inputs.spicetify-nix.homeManagerModules.default 
    #inputs.ssbm-nix.homeManagerModule
    ../../modules/home-manager/games.nix
    ../../modules/home-manager/obsidian.nix
    ../../modules/home-manager/utils
    ../../modules/home-manager/unity.nix
    ../../modules/home-manager/clojure.nix
  ];

  home.packages = with pkgs; [
    vesktop
    beeper
    element-desktop
    playerctl
    ncmpcpp
    wayfarer
    zoxide
    libqalculate
    xfce.thunar
    chromium
    vlc
    yt-dlp
    pinta    
    rustc
    cargo
    calibre

    wl-clipboard
    python313

    tree-sitter
    unzip
    wget
    curl
    fastfetch
    jq
    btop
    fzf
    keyd
 
    libnotify

    #gnome-tweaks
    swaybg
    flameshot
    networkmanagerapplet
    font-awesome
    nerd-fonts.code-new-roman
    nerd-fonts.fantasque-sans-mono
    rust-analyzer
    nil

    mesa-demos
    feh
    icoutils
    jq
    pywal
    fuzzel

    #Games (NB:Steam in configued in config):
    prismlauncher

    mangohud
    protonup-ng
    bottles
    gamescope

    wineWowPackages.waylandFull
    winetricks
    razergenie
    openrazer-daemon

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')

  ];

  programs = {
    ncmpcpp = {
      enable=true;
      mpdMusicDir = /mnt/storage/music;
    };
    lutris = {
      enable=true;
    };
    distrobox = {
     enable=true;
     enableSystemdUnit = true;
     containers = {
       ubunturocm = {
         image = "docker.io/library/ubuntu:latest";
         init_hooks = [
          "export LD_LIBRARY_PATH=\"/opt/rocm-6.4.1/lib:\$LD_LIBRARY_PATH\""
         ];
       };
     };
     };   
  zen-browser= {
   enable=true;
   policies = {
     DisableAppUpdate = true;
     DisableTelemetry = true;
   };
};
  lazygit = {
     enable=true;
  };
  git = {
    enable=true;
    settings= {
      user.name="crimsonneuron";
      user.email="james.r.devereux@gmail.com";
      init.defaultBranch = "main";
      core.editor="nvim";
    };
  };
  spicetify = 
    let 
      spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
    in 
    {
      enable = true;

      enabledExtensions = with spicePkgs.extensions; [
        adblock
        hidePodcasts
        shuffle # shuffle+ (special characters are sanitized out of extension names)
      ];
      enabledCustomApps = with spicePkgs.apps; [
        newReleases
        ncsVisualizer
      ];
      enabledSnippets = with spicePkgs.snippets; [
        rotatingCoverart
        pointer
      ];

      theme = spicePkgs.themes.catppuccin;
      colorScheme = "mocha";
      };

    swaylock.enable=true;
     #waybar = {
       #enable=true;
       ##systemd.enable=true;
     #};
  };

  games = {
    enable=true;
    titanfall2=true;
    melee=true;
    meleePath = "/mnt/storage/games/Slippi/isos/Super Smash Bros. Melee (USA) (En,Ja) (v1.02).iso";
    northstar =true;
    osu = true;
  };



   #slippi-launcher= {
     #isoPath = "/mnt/storage/games/Slippi/isos/Super Smash Bros. Melee (USA) (En,Ja) (v1.02).iso";
 #
     ##default path: /mnt/storage/games/Slippi/Super Smash Bros. Melee (USA) (En,Ja) (v1.02).iso
     ##20xx path: /mnt/storage/games/Slippi/isos/SSBM, 20XXHP 5.0.2.iso
     #launchMeleeOnPlay = true;
     #rootSlpPath = "/mnt/storage/games/Slippi/replays/";
     #useMonthlySubfolders  =true;
   #};

   #ssbm.slippi-launcher = {
     #enable=true;
     #isoPath = "/mnt/storage/games/Slippi/isos/Super Smash Bros. Melee (USA) (En,Ja) (v1.02).iso";
   #};

  services.podman = {
    enable=true;
  };
  services.udiskie = {
    enable = true;
  };
  services.mpd = {
    enable=true;
    musicDirectory = /mnt/storage/music;
    extraConfig = ''
      audio_output {
        type "pipewire"
        name "My PipeWire Output"
      }
    '';
  };

  services.swayidle.enable=true;
  services.polkit-gnome.enable=true;
  

   #systemd.user.services = {
     #xwayland-satellite = {
       #Unit = {
         #Description = "Thing for doing x11 only things";
         #BindsTo = ["graphical-session.target"];
         #PartOf = ["graphical-session.target"];
         #After = ["graphical-session.target"];
         #Requisite = ["graphical-session.target"];
       #};
       #Service = {
         #Type ="notify";
         #NotifyAccess= "all";
         #ExecStart = "${pkgs.xwayland-satellite}/bin/xwayland-satellite :0";
         #Restart = "on-failure";
         #Environment = "DISPLAY=:0";
       #};
       #Install = {
         #WantedBy = ["graphical-session.target"];
       #};
     #};
 #
     #swaybg = {
       #Unit = {
         #Description = "swaybg background setting";
         #BindsTo = ["graphical-session.target"];
         #PartOf = ["graphical-session.target"];
         #After = ["graphical-session.target"];
         #Requisite = ["graphical-session.target"];
       #};
 #
       #Service = {
         #ExecStart = "${pkgs.swaybg}/bin/swaybg -i /home/crimson/Pictures/Wallpapers/nasa_mirror_1920x1080.png";
       #};
       #Install = {
         #WantedBy = ["graphical-session.target"];
       #};
     #};
  #};
 #

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';

    "./.local/share/fonts" = {
      source= ../../resources/fonts;
      recursive = true;
    };

    
    
  };
  

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/crimson/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
    DISPLAY = ":0";
  };
  
  xdg = {
    configFile = {
     #"waybar/config.jsonc".source = ../../dotfiles/waybar/config.jsonc;
     #"waybar/style.css".source = ../../dotfiles/waybar/style.css;

    "containers/registries.conf".text = ''
      [registries.search]
      registries = ['docker.io', 'quay.io']
    '';
    "containers/policy.json".text = ''
      {
        "default": [
          {
            "type": "insecureAcceptAnything"
          }
        ]
      }
    '';
    "containers/storage.conf".text = ''
      [storage]
      driver = "overlay"
      graphroot = "/mnt/storage/distrobox"
    '';
    "fontconfig/conf.d/100-nix.conf".text = ''
      <?xml version="1.0"?>
      <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
      <fontconfig>
        <dir>~/.nix-profile/lib/X11/fonts</dir>
        <dir>~/.nix-profile/share/fonts</dir>
      </fontconfig>
    '';
    "tofi/config".source = ../../dotfiles/tofi/fullscreen;

    };

    mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" = "zen-beta.desktop";
        "x-scheme-handler/http" = "zen-beta.desktop";
        "x-scheme-handler/https" = "zen-beta.desktop";
        "x-scheme-handler/about" = "zen-beta.desktop";
        "x-scheme-handler/unknown" = "zen-beta.desktop";
        "inode/directory" = ["thunar.desktop"];
      };
    };
  };



 #dconf.settings = {
     #"org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
         #name = "Launch Alacritty";
         #command = "alacritty";
         #binding = "<Super>Return"; 
     #};
   #};

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
