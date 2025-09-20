inputs:

let
  # Get all .nix files in the current directory except default.nix itself
  nixFiles = builtins.filter (name: 
    name != "default.nix" && 
    builtins.match ".*\\.nix$" name != null
  ) (builtins.attrNames (builtins.readDir ./.));

  # Import each .nix file and create an attribute set
  importedModules = builtins.listToAttrs (map (file: {
    name = builtins.substring 0 (builtins.stringLength file - 4) file;
    value = import (./. + "/${file}") inputs;
  }) nixFiles);

in
importedModules
