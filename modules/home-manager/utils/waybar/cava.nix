{config, pkgs, ...}:

{
  programs.cava = {
    enable=true;
    settings = {
      general.framerate = 60;
      general.bars = 16;
      general.spacing =0;
      general.sensitivity = 100;
      
      input.method = "pipewire";
      input.source= "auto";

      output.method = "raw";
      output.raw_target = "/dev/stdout";
      output.data_format = "ascii";
      output.ascii_max_range = 7;
      output.bar_delimiter = "0";
    };
  };
}
