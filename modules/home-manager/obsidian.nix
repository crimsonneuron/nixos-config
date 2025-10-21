{pkgs,lib, ...}:

{
  home.packages = with pkgs; [
    obsidian
    veracrypt
  ];

  home.activation.createObsidianVault = lib.hm.dag.entryAfter ["writeBoundary"] ''
    cat > $HOME/.config/obsidian/obsidian.json << 'EOF'
    {"vaults":{"fbb49e6f697f76b6":{"path":"/run/media/veracrypt1/strongroom","ts":1760900415,"open":true}}}
    EOF
    '';
}

