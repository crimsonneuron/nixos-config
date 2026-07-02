{pkgs, config, osConfig, lib, ...}: 
let
  isLaptop = lib.hasInfix "l" (lib.toLower config.networking.hostName);
  flakeString = if isLaptop then " --flake ~/nixos#laptop" else " --flake ~/nixos#desktop";
in
{
    programs.zsh = {
      enable=true;
      
      shellAliases = {
        rebuild = "sudo nixos-rebuild switch" + flakeString;
        cleanup = "sudo nix-collect-garbage -delete-older-than 7d";
        test = "sudo nixos-rebuild test --impure" +flakeString;
        #The --impure is so that I can test without running a billion git add .s

      
        # homerebuild = "home-manager switch --flake ~/nixos#desktop";
      };
      initContent = ''
        export EDITOR=nvim
        export VISUAL=nvim
        export DISPLAY=:0
        eval "$(zoxide init zsh)"
        PROMPT='%F{#DBC713}%n@%m%f:%F{#DBC713}%~%f>'
        alias -- :q=exit

        '';
};
}
