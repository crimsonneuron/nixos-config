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
    rocq = mkEnableOption "Rocq";
  };

  config = mkIf cfg.enable {
    home.packages = lib.optionals cfg.rust[
      pkgs.rustc
      pkgs.cargo
      pkgs.rust-analyzer
    ] ++ lib.optionals cfg.OCaml[
      pkgs.dune_3
      pkgs.ocaml
      pkgs.ocamlPackages.utop
    ] ++ lib.optionals cfg.rocq[
        (pkgs.coq.withPackages (ps: with ps; [
          stdlib
          coq-lsp
        ]))
    ];
  };
}
