{config, pkgs, ...}:

{
  programs.cava = {
    enable=true;
    settings = {
      general.framerate = 15;
      general.bars = 16;
      general.spacing =0;
      
      
      input.method = "pulse";
      input.source= "84";

      output.method = "raw";
      output.raw_target = "/dev/stdout";
      output.bit_format = "8bit";
      output.ascii_max_range = 7;
    };
  };
}
