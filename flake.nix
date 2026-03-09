{ 
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  	zen-browser.url = "github:0xc000022070/zen-browser-flake";
    #slippi-nix.url = "github:lytedev/slippi-nix";
    ssbm-nix.url = "github:NormalFall/ssbm-nix";
    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    mnw.url = "github:Gerg-L/mnw";
    niri-flake.url = "github:sodiboo/niri-flake";
    noctalia = {
        url = "github:noctalia-dev/noctalia-shell";
        inputs.nixpkgs.follows = "nixpkgs";
    };
    vicinae = {
      url = "github:vicinaehq/vicinae";
    };

    nix-gaming = {
      url = "github:fufexan/nix-gaming";
    };
  };


  outputs = { self, nixpkgs,nixpkgs-unstable, ... }@inputs: 
  let 
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    pkgs-unstable = nixpkgs-unstable.legacyPackages.${system};
  in 
    {
      nixosConfigurations = {
	      desktop = nixpkgs.lib.nixosSystem {
          specialArgs = {inherit inputs pkgs-unstable;};
            modules = [
              ./hosts/desktop/configuration.nix
              inputs.home-manager.nixosModules.default {
                home-manager.extraSpecialArgs = {
                  inherit inputs pkgs-unstable;
                };
              }
            ];
          };
        laptop = nixpkgs.lib.nixosSystem {
          specialArgs = {inherit inputs pkgs-unstable;};
          modules = [
            ./hosts/laptop/configuration.nix
            inputs.home-manager.nixosModules.default {
            home-manager.extraSpecialArgs = {
              inherit inputs pkgs-unstable;
              };
            }
          ];
        };
     };
  };
}
