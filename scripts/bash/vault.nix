# Home Manager module for the encrypted notes vault.
#
# Place this next to the `vault` script and import it from your HM config:
#
#   imports = [ ./vault.nix ];
#
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
      install -Dm755 ${./vault} $out/bin/vault
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

  # Catches the case where the vault sits open for days and so never hits the
  # on-open / on-close backup hooks. Exits 1 harmlessly when the vault is
  # closed, hence SuccessExitStatus.
  systemd.user.services.vault-backup = {
    Unit.Description = "Snapshot the notes vault, if it is open";
    Service = {
      Type = "oneshot";
      ExecStart = "${lib.getExe vault} backup";
      SuccessExitStatus = "0 1";
    };
  };

  systemd.user.timers.vault-backup = {
    Unit.Description = "Hourly notes vault snapshot";
    Timer = {
      OnCalendar = "hourly";
      Persistent = true;
      RandomizedDelaySec = "5m";
    };
    Install.WantedBy = [ "timers.target" ];
  };
}
