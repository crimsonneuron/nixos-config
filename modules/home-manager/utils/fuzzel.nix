{pkgs, ...}:

{
  programs.fuzzel = {
    enable=true;
    settings = {
      main = {
        terminal = "${pkgs.kitty}/bin/kitty"; 
        layer = "overlay";
        exit-on-keyboard-focus-loss = true;
      };
      
      colors = {
        background = "1e1e2eff";
        text = "cdd6f4ff";
        selection = "313244ff";
        selection-text = "cdd6f4ff";
        match = "f38ba8ff";
      };
      
      border = {
        width = 2;
        radius = 8;
      };
      
      fonts = {
        font = "JetBrains Mono:size=12";
      };
    };
  };
}
