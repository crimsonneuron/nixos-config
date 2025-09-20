inputs:

let
  # Get all .nix files in the current directory except default.nix itself
  nixFiles = builtins.filter (name: 
    name != "default.nix" && 
    inputs.nixpkgs.lib.hasSuffix ".nix" name
  ) (builtins.attrNames (builtins.readDir ./.));

  # Import each .nix file and create an attribute set
  importedModules = builtins.listToAttrs (map (file: {
    name = inputs.nixpkgs.lib.removeSuffix ".nix" file;
    value = import (./. + "/${file}") inputs;
  }) nixFiles);

in
importedModules
