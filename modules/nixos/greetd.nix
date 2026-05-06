{inputs, pkgs,...}: 

{
  services.greetd = {
    enable= true;
    settings = {
      terminal.vt = 2;
      default.session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --remember --remember-session --time";
        user = "greeter";
      };

    };
  };
}
