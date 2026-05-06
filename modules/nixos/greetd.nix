{inputs, pkgs, lib, ...}: 

{
  services.greetd = {
    enable= true;
    settings = {
      terminal.vt = lib.mkForce 2;
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --remember --remember-session --time --sessions ${pkgs.niri}/share/wayland-sessions";
        user = "greeter";
      };

    };
  };
}
