{ 
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  	zen-browser.url = "github:0xc000022070/zen-browser-flake";
    #slippi-nix.url = "github:lytedev/slippi-nix";
    ssbm-nix.url = "github:NormalFall/ssbm-nix";
    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    nixvim = {
      url = "github:nix-community/nixvim/nixos-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs: 
  let 
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in 
    {
      nixosConfigurations = {
	      desktop = nixpkgs.lib.nixosSystem {
          specialArgs = {inherit inputs;};
            modules = [
              ./configuration.nix
              inputs.home-manager.nixosModules.default
            ];
          };
     };
  };
}
