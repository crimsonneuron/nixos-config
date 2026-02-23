{pkgs, inputs, ...}:
#See the HM module games.nix for the actual config of this, its just that
#The gcc adapter needs to be in a nix file. :\
{
  imports  = [inputs.ssbm-nix.overlay];
  ssbm.gcc = {
    rules.enable =true;
    oc-kmod.enable =true;
  };
  
}
