{
  lib,
  stdenv,
  fetchFromGitHub,
  gnat,
  gprbuild,
  makeWrapper,
}:

stdenv.mkDerivation {
  pname = "whitakers-words";
  # Convention for untagged projects: 0-unstable-<commit date>
  version = "0-unstable-2025-01-01";

  src = fetchFromGitHub {
    owner = "mk270";
    repo = "whitakers-words";
    # Fill these in with the output of:
    #   nix run nixpkgs#nix-prefetch-github -- mk270 whitakers-words
    rev = "1f2f0fb0867a896d7b9284a03d615ed635d6f992";
    hash = "sha256-hTeBL3RBlUbJj/4bYj73Z6qCmoRee8KIAYrVQZmztnc=";
  };

  nativeBuildInputs = [
    gnat
    gprbuild
    makeWrapper
  ];


  # Upstream hardcodes -j4; use however many cores Nix gives us.
  preBuild = ''
    makeFlagsArray+=("GPRBUILD_OPTIONS=-j$NIX_BUILD_CORES")
  '';

  # There's no `make install`, so copy the binary and data by hand.
  installPhase = ''
    runHook preInstall

    install -Dm755 -t $out/bin bin/words
    install -Dm644 -t $out/share/whitakers-words *.GEN *.SEC *.LAT
    install -Dm644 -t $out/share/doc/whitakers-words *.htm *.txt || true
    wrapProgram $out/bin/words \
     --set-default WHITAKERS_WORDS_DATADIR $out/share/whitakers-words

    runHook postInstall
  '';

  meta = {
    description = "William Whitaker's WORDS, a Latin-English dictionary and morphological analyser";
    homepage = "https://github.com/mk270/whitakers-words";
    license = lib.licenses.free;
    mainProgram = "words";
    platforms = lib.platforms.unix;
  };
}
