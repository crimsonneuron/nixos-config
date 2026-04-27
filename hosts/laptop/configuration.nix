# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      inputs.home-manager.nixosModules.default
      # ../../modules/nixos/games.nix
      ../../modules/nixos/keyboard.nix
      ../../modules/nixos/niri.nix
      ../../modules/nixos/fonts.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "lsla"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };
  
  # Enable the X11 windowing system.
  #services.xserver.enable = true;

  services.displayManager.ly.enable=true;
  services.udisks2.enable=true;
  services.upower = {
    enable =true;
  };

  hardware.graphics.enable=true;


  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Experimental = true; # Show battery charge of Bluetooth devices
      };
    };
  };
  

  services.blueman.enable=true;




  #XRDP Remote Desktop Server setup
   #services.xrdp = {
     #enable= true;
     #defaultWindowManager = "gnome-remote-desktop";
     #audio.enable =true;
     #openFirewall = true;
 #
   #};

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.crimson = {
    isNormalUser = true;
    description = "James Devereux";
    extraGroups = [ "networkmanager" "wheel" "video" "input" "audio" "render"];
    packages = with pkgs; [
    #  thunderbird
    ];
    shell = pkgs.zsh;
    hashedPassword = "$6$FmPqvbAaTymXAgCG$4zeToftuip2hp1MlKS7Na3FTQd4PevFp5ziUEvrJ5wBHXZUcFJZdSIc1pqd3Pu2EklKShARQ3pLEd4CkRUtl2";
  };
    home-manager = {
      extraSpecialArgs = {inherit inputs;};
      users = {
        "crimson" = import ./home.nix;
    };
    backupFileExtension = "bkup";
  };
  
  programs.zsh = {
    enable=true;
  };

  programs.steam = {
    enable=true;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  nix = {
    extraOptions = "experimental-features = nix-command flakes";
    settings = {
      extra-substituters = [
        "https://vicinae.cachix.org"
      ];
      extra-trusted-public-keys = [
        "vicinae.cachix.org-1:1kDrfienkGHPYbkpNj1mWTr7Fm1+zcenzgTizIcI3oc=" 
      ];
    };
  };
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    neovim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    kitty 
    yazi 
    p7zip

    gcc
    gnumake
    cmake
    pkg-config

    home-manager
    
    gnome-remote-desktop
    wiremix

    #distrobox
    #podman

    #rocm:

  ];

  systemd.user.services."init-session" = {
      description = "Initialize systemd user session for Wayland";
      wantedBy = [ "default.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.systemd}/bin/systemd --user";
        # Critical: Don't fork! Must stay attached to TTY
        Type = "simple";
        # Ensure it runs BEFORE compositor
        Before = [ "sway.service" "niri.service" ];
      };
    };
    environment.sessionVariables.NIXOS_OZONE_WL = "1";

    environment.etc."gitconfig".text = ''
    [safe]
      directory=/home/crimson/nixos
  '';

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:
  
  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;
  security.polkit.enable=true;
  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

}
