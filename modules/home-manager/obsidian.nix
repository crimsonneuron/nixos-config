{ config, lib, pkgs, ... }:

let
  # Everything the script calls by name. Baked into the script's own PATH so it
  # works identically from a shell, the application picker, and systemd — none
  # of which share the same environment.
  runtimeDeps = with pkgs; [
    veracrypt
    restic
    git
    coreutils     # date, stat, df, mkdir, sync, install
    util-linux    # mountpoint, findmnt
    psmisc        # fuser, for the "dismount failed" diagnostics
    hostname
  ];

  vault = pkgs.runCommand "vault"
    {
      nativeBuildInputs = [ pkgs.makeWrapper ];
      meta.mainProgram = "vault";
    }
    ''
      install -Dm755 ${/home/crimson/nixos/scripts/bash/vault.sh} $out/bin/vault
      wrapProgram $out/bin/vault \
        --prefix PATH : ${lib.makeBinPath runtimeDeps}
    '';

  # sudo deliberately isn't in runtimeDeps: on NixOS the working sudo is the
  # setuid wrapper at /run/wrappers/bin, which is already on your PATH. The
  # nixpkgs `sudo` binary isn't setuid and would fail.

  # If your desktop ignores Terminal=true (GNOME often does), set this to your
  # terminal's "run this command and stay open" invocation instead.
  #   kitty     = "${pkgs.kitty}/bin/kitty --hold -e";
  #   alacritty = "${pkgs.alacritty}/bin/alacritty --hold -e";
  #   foot      = "${pkgs.foot}/bin/foot --hold";
  #   konsole   = "${pkgs.kdePackages.konsole}/bin/konsole --hold -e";
  terminalPrefix = null;

  launchCmd =
    let base = "${pkgs.coreutils}/bin/env VAULT_FROM_LAUNCHER=1 ${lib.getExe vault}";
    in if terminalPrefix == null then base else "${terminalPrefix} ${base}";
in
{
  home.packages = [ vault ] ++ runtimeDeps;

  xdg.desktopEntries.vault = {
    name = "Notes Vault";
    genericName = "Encrypted notes";
    comment = "Open or close the encrypted notes vault";
    exec = launchCmd;
    icon = "drive-removable-media";
    terminal = terminalPrefix == null;
    type = "Application";
    categories = [ "Utility" ];
  };

}

