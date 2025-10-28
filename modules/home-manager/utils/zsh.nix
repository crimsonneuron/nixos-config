{pkgs, config, ...}: 
let
  isLaptop = builtins.pathExists /sys/class/power_supply/BAT0 ||
    builtins.pathExists /sys/class/power_supply/BAT1;
  flakeString = if isLaptop then " --flake ~/nixos#laptop" else " --flake ~/nixos#desktop";
in
{
    programs.zsh = {
      enable=true;
      
      shellAliases = {
        rebuild = "sudo nixos-rebuild switch" + flakeString;
        cleanup = "sudo nix-collect-garbage -d";
        test = "sudo nixos-rebuild test --impure" +flakeString;
        #The --impure is so that I can test without running a billion git add .s

      
        # homerebuild = "home-manager switch --flake ~/nixos#desktop";
      };
      initContent = ''
        export EDITOR=nvim
        export VISUAL=nvim
        export DISPLAY=:0
        eval "$(zoxide init zsh)"
        alias -- :q=exit
        '';
};
}
