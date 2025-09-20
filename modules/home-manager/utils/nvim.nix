# modules/neovim.nix
{ pkgs, ... }:

{
  programs.nixvim = {
    enable = true;

    # Set leader keys
    globals = {
      mapleader = ",";
      maplocalleader = "\\";
    };

    # Options (opts.lua equivalent)
    opts = {
      # Context
      colorcolumn = "80";
      number = true;
      relativenumber = true;
      scrolloff = 4;
      signcolumn = "yes";

      # Filetypes
      encoding = "utf-8";
      fileencoding = "utf-8";

      # Theme
      syntax = "ON";
      termguicolors = true;
      background = "light"; # Note: This overrides the 'dark' set in vars.lua

      # Search
      ignorecase = true;
      smartcase = true;
      incsearch = true;
      hlsearch = false;

      # Whitespace
      expandtab = true;
      shiftwidth = 4;
      softtabstop = 4;
      tabstop = 4;

      # Splits
      splitright = true;
      splitbelow = true;

      # Completion
      completeopt = [ "menuone" "noselect" "noinsert" ];
      shortmess = "filnxtToOFc"; # Approximation, adds 'c'

      # Diagnostics & UI (from autocmds and set commands)
      # updatetime is usually handled by Nixvim's LSP module
      # signcolumn is set above
      # Conceal settings for json/jsonc would need specific buffer configuration
      # Folding options are set in the treesitter section below
    };

    # Colorscheme (opts.lua)
    colorschemes.kanagawa.enable = true;

    # Variables (vars.lua equivalent)
    # t_co=256 is usually default
    # background is set in opts
    # packpath modification is usually not needed in Nixvim

    # Keymaps (keys.lua equivalent)
    keymaps = [
      # Remap escape
      {
        mode = "i";
        key = "jk";
        action = "<Esc>";
        options = {
          noremap = true;
          silent = true;
        };
      }
      # Toggle Telescope find files (Note: ff is a common key for this)
      {
        mode = "n";
        key = "ff";
        action = "<cmd>Telescope find_files<cr>";
        options.noremap = true;
      }
      # Rust Tools keymaps (Defined in LSP section below)
      # {
      #   mode = "n";
      #   key = "<C-space>";
      #   action = "<Plug>(rust-tools-hover-actions)";
      #   options = { silent = true; };
      # }
      # {
      #   mode = "n";
      #   key = "<Leader>a";
      #   action = "<Plug>(rust-tools-code-action-group)";
      #   options = { silent = true; };
      # }
    ];

    # Plugins Configuration
    plugins = {
      # Ensure required plugins are installed
      telescope.enable = true;
      nvim-autopairs.enable = true;
      nvim-cmp.enable = true;
      cmp-nvim-lsp.enable = true; # For nvim_lsp source
      cmp-vsnip.enable = true;    # For vsnip source
      cmp-buffer.enable = true;   # For buffer source
      cmp-path.enable = true;     # For path source
      cmp-calc.enable = true;     # For calc source
      vim-vsnip.enable = true;    # Required for cmp-vsnip
      nvim-treesitter = {
        enable = true;
        # ensureInstalled = [ "lua" "rust" ]; # Uncomment if you want specific parsers
        # autoInstall = true; # Nixvim handles this differently, usually via ensureInstalled
        nixvimInjections = true; # Enable Nix specific injections
        indent = true;
        folding = true; # Enables treesitter folding
        rainbow = {
          enable = true;
          extendedMode = true;
          maxFileLines = null;
        };
        # parserInstallDir is handled by Nixvim
      };
      # LSP Configuration
      lsp = {
        enable = true;
        # Enable servers
        servers = {
          rust-analyzer.enable = true;
          nil_ls.enable = true; # For Nix
        };
        # Configure diagnostics signs and float
        # This part configures the appearance and behavior of diagnostics
        # It roughly corresponds to the sign_define and vim.diagnostic.config parts
        # and the autocmd for CursorHold in your init.lua
        # The keymap for diagnostics is usually provided by default or the which-key plugin
        # Signs
        # signs = {
        #   DiagnosticSignError = { text = ""; texthl = "DiagnosticSignError"; };
        #   DiagnosticSignWarn = { text = ""; texthl = "DiagnosticSignWarn"; };
        #   DiagnosticSignHint = { text = ""; texthl = "DiagnosticSignHint"; };
        #   DiagnosticSignInfo = { text = ""; texthl = "DiagnosticSignInfo"; };
        # };
        # Diagnostic Configuration
        # diagnostics = {
        #   virtualText = false;
        #   signs = true;
        #   updateInInsert = true;
        #   underline = true;
        #   severitySort = false;
        #   float = {
        #     border = "rounded";
        #     source = "always";
        #     header = "";
        #     prefix = "";
        #   };
        # };
        # Keymaps for LSP functions (like hover, definition, etc.)
        # These are common defaults, you can customize them
        # keymaps = {
        #   silent = true;
        #   lspBuf = {
        #     gd = "<cmd>lua vim.lsp.buf.definition()<CR>";
        #     gD = "<cmd>lua vim.lsp.buf.declaration()<CR>";
        #     gr = "<cmd>lua vim.lsp.buf.references()<CR>";
        #     gi = "<cmd>lua vim.lsp.buf.implementation()<CR>";
        #     K = "<cmd>lua vim.lsp.buf.hover()<CR>";
        #     "<C-k>" = "<cmd>lua vim.lsp.buf.signature_help()<CR>";
        #     "<F2>" = "<cmd>lua vim.lsp.buf.rename()<CR>";
        #     "<F4>" = "<cmd>lua vim.lsp.buf.code_action()<CR>";
        #     ge = "<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>";
        #     g0 = "<cmd>lua vim.lsp.buf.document_symbol()<CR>";
        #     gW = "<cmd>lua vim.lsp.buf.workspace_symbol()<CR>";
        #   };
        # };
      };
      # Rust Tools configuration (if you want to use rust-tools.nvim features beyond LSP)
      # rust-tools = {
      #   enable = true;
      #   # server = {
      #   #   onAttach = ''
      #   #     function(_, bufnr)
      #   #       -- Hover actions
      #   #       vim.keymap.set("n", "<C-space>", require('rust-tools').hover_actions.hover_actions, { buffer = bufnr })
      #   #       -- Code action groups
      #   #       vim.keymap.set("n", "<Leader>a", require('rust-tools').code_action_group.code_action_group, { buffer = bufnr })
      #   #     end
      #   #   '';
      #   # };
      # };
      # Vimspector configuration (if you are using vimspector)
      # vimspector = {
      #   enable = true;
      #   settings = {
      #     sidebar_width = 85;
      #     bottombar_height = 15;
      #     terminal_maxwidth = 70;
      #   };
      # };
    };

    # Extra configuration (for parts not directly supported by Nixvim modules)
    extraConfigLua = ''
      -- Set updatetime for CursorHold (if needed, often default is fine)
      vim.api.nvim_set_option('updatetime', 300)

      -- Autocmd for CursorHold diagnostic float (handled by LSP diagnostics config above)
      -- vim.api.nvim_create_autocmd("CursorHold", {
      --   pattern = "*",
      --   callback = function()
      --     vim.diagnostic.open_float(nil, { focusable = false })
      --   end,
      -- })

      -- Autocmd for FileType json/jsonc conceal (Nixvim might have specific ways)
      -- Consider using `programs.nixvim.plugins.treesitter.context` or similar
      -- vim.api.nvim_create_autocmd("FileType", {
      --   pattern = { "json", "jsonc" },
      --   callback = function()
      --     vim.opt_local.concealcursor = "nvic"
      --   end,
      -- })

      -- Autocmd for Nix filetype settings
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "nix",
        callback = function()
          vim.bo.tabstop=2
          vim.bo.shiftwidth=2
          vim.bo.softtabstop=2
          vim.bo.expandtab=true
        end
      })

      -- Treesitter folding setup (often handled by plugins.nvim-treesitter.folding)
      -- vim.wo.foldmethod = 'expr'
      -- vim.wo.foldexpr = 'nvim_treesitter#foldexpr()'

      -- Completion Plugin Setup (Handled by plugins.nvim-cmp)
      -- The cmp setup in your init.lua is largely covered by the Nixvim plugin options
      -- You might need to add specific sources or mappings via extraOptions or extraConfigLua if defaults aren't enough
    '';
  };
}
