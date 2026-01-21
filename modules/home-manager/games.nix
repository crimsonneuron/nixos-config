{config, lib, pkgs, inputs, ...}: 
with lib;
let 
  cfg = config.games;
in
{
  imports = [
    inputs.ssbm-nix.homeManagerModule
  ];
  
  options.games = {
    enable = mkEnableOption "Games Module";
    titanfall2 = mkEnableOption "Titanfall 2";
    northstar = mkEnableOption "Northstar";
    melee = mkEnableOption "Super Smash Bros Melee";
    meleePath = mkOption {
      type = types.str;
      description = "Path to the default iso file";
    };
    osu = mkEnableOption "Osu!";
  };
  
  config = mkIf cfg.enable {
    # Titanfall 2 configuration
    home.file = mkIf cfg.titanfall2 {
      ".local/share/applications/titanfall2.desktop".text = ''
        [Desktop Entry]
        Type=Application
        Name=Titanfall 2
        Exec= lutris lutris:rungame/titanfall-2"
        Icon=/home/crimson/.local/share/icons/hicolor/128x128/apps/lutris_titanfall-2.png
        Categories=Game;
      '';
    };

    home.packages = []
      ++ lib.optionals cfg.northstar [
        inputs.nix-gaming.packages.${pkgs.stdenv.hostPlatform.system}.northstar-proton
        inputs.nix-gaming.packages.${pkgs.stdenv.hostPlatform.system}.viper
    ]
    ++ lib.optionals cfg.osu [
        inputs.nix-gaming.packages.${pkgs.stdenv.hostPlatform.system}.osu-lazer-bin
      ];


   


    # Melee configuration - this goes directly at config root level
    ssbm.slippi-launcher = mkIf cfg.melee {
      enable = true;
      isoPath = cfg.meleePath;
    };
  };
}
