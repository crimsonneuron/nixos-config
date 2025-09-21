{config, pkgs, ...}:

{
  programs.cava = {
    enable=true;
    settings = {
      general.framerate = 60;
      general.bars = 16;
      general.spacing =0;
      
      
      input.method = "pipewire";
      input.source= "auto";
      input.sensitivity= 100;

      output.method = "raw";
      output.raw_target = /dev/stdout;
      output.bit_format = "8bit";
      output.ascii_max_range = 7;

      smoothing.monstercat = 1;
      smoothing.noise-reduction =0.77;
    };
  };
}
