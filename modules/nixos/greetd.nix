{inputs, pkgs, lib, ...}: 

{
  services.greetd = {
    enable= true;
    settings = {
      terminal.vt = lib.mkForce 2;
      default.session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --remember --remember-session --time";
        user = "greeter";
      };

    };
  };
}
