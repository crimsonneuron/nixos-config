{ pkgs,inputs, ... }: {
  imports=[inputs.nixvim.homeManagerModules.nixvim];
  programs.nixvim = {
    enable = true;

    # Global variables (from vars.lua)
    globals = {
      mapleader = ",";
      localleader = "\\";
      t_co = 256;
      background = "dark";
    };

    # Options (from opts.lua)
    opts = {
      # Context
      colorcolumn = "80";
      number = true;
      relativenumber = true;
      scrolloff = 4;
      signcolumn = "yes";

      # Filetypes
      encoding = "utf8";
      fileencoding = "utf8";

      # Theme
      termguicolors = true;
      background = "light";  # Note: you had this set to light in opts.lua

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
      completeopt = ["menuone" "noselect" "noinsert"];
      updatetime = 300;

      # Folding
      foldmethod = "expr";
      foldexpr = "nvim_treesitter#foldexpr()";
      foldlevel = 999;
      foldlevelstart = 999;
    };

    # Colorscheme
    colorschemes.kanagawa = {
      enable = true;
    };

    # Keymaps (from keys.lua)
    keymaps = [
      {
        mode = "i";
        key = "jk";
        action = "<Esc>";
        options = {
          noremap = true;
          silent = true;
        };
      }
      {
        mode = "n";
        key = "ff";
        action = ":Telescope find_files<CR>";
        options = {
          noremap = true;
          silent = true;
        };
      }
    ];

    # Plugin configurations
    plugins = {
      # File finder
      telescope = {
        enable = true;
        keymaps = {
          "<leader>ff" = "find_files";
          "<leader>fg" = "live_grep";
          "<leader>fb" = "buffers";
          "<leader>fh" = "help_tags";
        };
      };

      # Treesitter
      treesitter = {
        enable = true;
        settings = {
          highlight = {
            enable = true;
            additional_vim_regex_highlighting = false;
          };
          indent = {
            enable = true;
          };
          rainbow = {
            enable = true;
            extended_mode = true;
            max_file_lines = null;
          };
        };
      };

      # LSP
      lsp = {
        enable = true;
        servers = {
          rust-analyzer = {
            enable = true;
            installCargo = false;
            installRustc = false;
          };
          nil-ls = {
            enable = true;
          };
        };
      };

      # Completion
      cmp = {
        enable = true;
        autoEnableSources = true;  # This automatically enables source plugins
        settings = {
          snippet = {
            expand = "function(args) require('luasnip').lsp_expand(args.body) end";
          };
          mapping = {
            "<C-p>" = "cmp.mapping.select_prev_item()";
            "<C-n>" = "cmp.mapping.select_next_item()";
            "<S-Tab>" = "cmp.mapping.select_prev_item()";
            "<Tab>" = "cmp.mapping.select_next_item()";
            "<C-S-f>" = "cmp.mapping.scroll_docs(-4)";
            "<C-f>" = "cmp.mapping.scroll_docs(4)";
            "<C-Space>" = "cmp.mapping.complete()";
            "<C-e>" = "cmp.mapping.close()";
            "<CR>" = "cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Insert, select = true })";
          };
          sources = [
            { name = "nvim_lsp"; keyword_length = 3; }
            { name = "luasnip"; keyword_length = 2; }
            { name = "path"; }
            { name = "buffer"; keyword_length = 2; }
            { name = "nvim_lua"; keyword_length = 2; }
            { name = "calc"; }
          ];
          window = {
            completion = {
              border = "rounded";
            };
            documentation = {
              border = "rounded";
            };
          };
          formatting = {
            fields = ["menu" "abbr" "kind"];
            format = ''
              function(entry, item)
                local menu_icon = {
                  nvim_lsp = 'λ',
                  luasnip = '⋗',
                  buffer = 'Ω',
                  path = '🖫',
                }
                item.menu = menu_icon[entry.source.name]
                return item
              end
            '';
          };
        };
      };

      # Snippet support with LuaSnip
      luasnip.enable = true;

      # Auto pairs
      nvim-autopairs = {
        enable = true;
      };


    };

    # Extra packages for plugins not directly supported by NixVim
    extraPlugins = with pkgs.vimPlugins; [
      rust-tools-nvim
    ];

    # Extra Lua configuration for things that don't have direct NixVim equivalents
    extraConfigLua = ''
      -- Rust-tools setup
      local rt = require("rust-tools")
      rt.setup({
        server = {
          on_attach = function(_, bufnr)
            -- Hover actions
            vim.keymap.set("n", "<C-space>", rt.hover_actions.hover_actions, { buffer = bufnr })
            -- Code action groups
            vim.keymap.set("n", "<Leader>a", rt.code_action_group.code_action_group, { buffer = bufnr })
          end,
        },
      })
      -- Shortmess configuration
      vim.opt.shortmess = vim.opt.shortmess + { c = true }

      -- LSP Diagnostics signs
      local sign = function(opts)
        vim.fn.sign_define(opts.name, {
          texthl = opts.name,
          text = opts.text,
          numhl = ""
        })
      end

      sign({name = "DiagnosticSignError", text = "🔥"})
      sign({name = "DiagnosticSignWarn", text = "⚠️"})
      sign({name = "DiagnosticSignHint", text = "💡"})
      sign({name = "DiagnosticSignInfo", text = "ℹ️"})

      -- Diagnostic configuration
      vim.diagnostic.config({
          virtual_text = false,
          signs = true,
          update_in_insert = true,
          underline = true,
          severity_sort = false,
          float = {
              border = "rounded",
              source = "always",
              header = "",
              prefix = "",
          },
      })

      -- Auto commands
      vim.cmd([[
          autocmd CursorHold * lua vim.diagnostic.open_float(nil, { focusable = false })
          autocmd FileType json,jsonc setlocal concealcursor=nvic
      ]])

      -- Nix file specific settings
      vim.api.nvim_create_autocmd("FileType", {
          pattern = "nix",
          callback = function()
              vim.bo.tabstop = 2
              vim.bo.shiftwidth = 2
              vim.bo.softtabstop = 2
              vim.bo.expandtab = true
          end
      })

      -- Vimspector options (if you're using it)
      vim.cmd([[
          let g:vimspector_sidebar_width = 85
          let g:vimspector_bottombar_height = 15
          let g:vimspector_terminal_maxwidth = 70
      ]])
    '';
  };
}
