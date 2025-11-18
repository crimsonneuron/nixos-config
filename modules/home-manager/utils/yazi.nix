{pkgs,...}:
let
  yazi-plugins = pkgs.fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "8f1d9711bcd0e48af1fcb4153c16d24da76e732d";
    sha256 = "sha256-7vsqHvdNimH/YVWegfAo7DfJ+InDr3a1aNU0f+gjcdw=";
  };
  kanagawaFlavor = pkgs.fetchFromGitHub {
    owner = "dangooddd";
    repo = "kanagawa.yazi";
    rev = "a0b1d9dec31387b5f8a82c96044e6419b6c46534";
    sha256 = "sha256-nGFiAgVWfq7RkuGGCt07zm3z7ZTGiIPIR319ojPfdUk=";
  };
in
{
  programs.yazi ={
    enable=true;
    enableZshIntegration=true;
    shellWrapperName = "y";
    plugins = {
      full-border = "${yazi-plugins}/full-border.yazi";
    };
    flavors = {
      "kanagawa" = kanagawaFlavor;
    };
    theme = {
      flavor = {
        dark = "kanagawa";
        light = "kanagawa";
      };
    };
  };
}
