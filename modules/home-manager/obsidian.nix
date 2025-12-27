{pkgs,lib, ...}:

{
  home.packages = with pkgs; [
    obsidian
    veracrypt
    bitwarden-cli
  ];

  home.activation.createObsidianVault = lib.hm.dag.entryAfter ["writeBoundary"] ''
    cat > $HOME/.config/obsidian/obsidian.json << 'EOF'
    {"vaults":{"fbb49e6f697f76b6":{"path":"/run/media/veracrypt1/strongroom","ts":1760900415,"open":true}}}
    EOF
    '';

  home.file = {
    ".local/share/applications/ObsidianDecrypt.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=ObsidianDecrypt
      Exec=kitty --hold sh -c "~/nixos/scripts/python/obsilogin.py"
      Icon=utilities-terminal
      Terminal=false
    '';
  };
}

