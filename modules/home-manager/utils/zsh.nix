{pkgs, ...}: 

{
    programs.zsh = {
      enable=true;
      
      shellAliases = {
        rebuild = "sudo nixos-rebuild switch --flake ~/nixos#laptop";
        cleanup = "sudo nix-collect-garbage -d";
        test = "sudo nixos-rebuild test --flake ~/nixos#laptop";
        # homerebuild = "home-manager switch --flake ~/nixos#desktop";
      };
      initContent.exports = " 
        export EDITOR=nvim
        export VISUAL=nvim
        export DISPLAY=:0
        eval \"$(zoxide init zsh)\"
        alias :q=exit
        ";
};
}
