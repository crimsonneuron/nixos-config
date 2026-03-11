{pkgs,lib, inputs,config, ...}:
with lib;
let
  cfg =config.languages;
in
{
 options.languages = {
    enable = mkEnableOption "Programming Languages Module";
    rust = mkEnableOption "Rust";
    OCaml = mkEnableOption "OCaml";
  };

  config = mkIf cfg.enable {
    home.packages = lib.optionals cfg.rust[
      rustc
      cargo
      rust-analyzer
  ] ++ lib.optionals cfg.OCaml[
    opam
    ocaml
  ] ++ [];
    };
}
