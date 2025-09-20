{ config, pkgs, ... }:

let
  # Get all .nix files in the current directory except default.nix itself
  nixFiles = builtins.filter (name: 
    name != "default.nix" && 
    builtins.match ".*\\.nix$" name != null
  ) (builtins.attrNames (builtins.readDir ./.));

  # Import each .nix file as a Home Manager module
  moduleImports = map (file: ./. + "/${file}") nixFiles;

in
{
  imports = moduleImports;
}
