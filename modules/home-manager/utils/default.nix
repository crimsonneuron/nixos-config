{ pkgs ? import <nixpkgs> {} }:

let
  # Get all .nix files in the current directory except default.nix itself
  nixFiles = builtins.filter (name: 
    name != "default.nix" && 
    pkgs.lib.hasSuffix ".nix" name
  ) (builtins.attrNames (builtins.readDir ./.));

  # Import each .nix file and create an attribute set
  importedModules = builtins.listToAttrs (map (file: {
    name = pkgs.lib.removeSuffix ".nix" file;
    value = import (./. + "/${file}") { inherit pkgs; };
  }) nixFiles);

in
importedModules
