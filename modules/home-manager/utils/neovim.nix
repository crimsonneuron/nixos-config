{ pkgs, inputs, ... }:
{
  imports = [ inputs.mnw.homeManagerModules.mnw ];

  programs.mnw = {
    enable = true;

    # LSP server binaries and tools go on PATH
    extraBinPath = with pkgs; [
      nil              # nil_ls for Nix
      ripgrep          # telescope live_grep
    ];

    # Lua packages needed by plugins
    extraLuaPackages = ps: [ ];

    plugins.dev.myconfig = {
      pure   = ../../../dotfiles/nvim;          # used in normal builds
      impure = "/home/crimson/nixos/dotfiles/nvim";  # TODO: update to your actual path
    };

    plugins.start = with pkgs.vimPlugins; [
      # Colourscheme
      kanagawa-nvim

      # Core
      nvim-web-devicons
      nvim-treesitter.withAllGrammars
      telescope-nvim
      plenary-nvim           # telescope dependency

      # LSP
      nvim-lspconfig

      # Completion
      nvim-cmp
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      cmp-nvim-lua
      cmp-calc
      luasnip
      cmp_luasnip

      # Editing
      nvim-autopairs
      nvim-surround

      # Clojure / REPL
      conjure

      # Rust
      rustaceanvim
    ];

    initLua = ''
      require("config.options")
      require("config.keymaps")
      require("config.autocmds")
      require("config.lsp")
      require("config.cmp")
      require("config.plugins")
    '';
  };
}
