{pkgs, pkgs-unstable, inputs, lib,...}:
let
  spotifast = pkgs-unstable.spotifast;
  spotifast-fixed = pkgs.runCommand "spotifast-${spotifast.version}" { } ''
    mkdir -p $out/bin
    grep -v libpulseaudio ${spotifast}/bin/spotifast > $out/bin/spotifast
    chmod +x $out/bin/spotifast
    if [ -d ${spotifast}/share ]; then
      cp -r ${spotifast}/share $out/share
      chmod -R u+w $out/share
      find $out/share -name '*.desktop' -exec sed -i "s|${spotifast}|$out|g" {} +
    fi
  '';
in
{
  home.packages = [
    spotifast-fixed
    pkgs-unstable.soloist
  ];
   
}
