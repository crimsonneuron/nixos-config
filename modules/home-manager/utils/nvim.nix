{ config, pkgs, lib,inputs, ... }:

{
  imports = [inputs.nixvim.homeManagerModules.nixvim];
  # Neovim configuration module for NixOS with flakes
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    
    # Basic configuration from vars.txt and opts.txt
    extraConfig = ''
      set t_Co=256
      let g:background = "dark"
      set colorcolumn=80
      set number
      set relativenumber
      set scrolloff=4
      set signcolumn=yes
      set encoding=utf8
      set fileencoding=utf8
      syntax on
      set termguicolors
      colorscheme kanagawa
      set ignorecase
      set smartcase
      set incsearch
      set nohlsearch
      set expandtab
      set shiftwidth=4
      set softtabstop=4
      set tabstop=4
      set splitright
      set splitbelow
      set completeopt=menuone,noselect,noinsert
      set shortmess+=c
      let &updatetime=300
      set signcolumn=yes
      autocmd CursorHold * lua vim.diagnostic.open_float(nil, { focusable = false })
      autocmd FileType json,jsonc setlocal concealcursor=nvic
      set foldmethod=expr
      set foldexpr=nvim_treesitter#foldexpr()
    '';
    
    # Leader key setup from init.txt
    customRC = ''
      let mapleader=","
      let maplocalleader="\\"
      
      " Key mappings from keys.txt
      inoremap jk <Esc>
      nnoremap ff :Telescope find_files<CR>
    '';
    
    # Plugins from init.txt
    plugins = with pkgs.vimPlugins; [
      nvim-treesitter
      nvim-lspconfig
      nvim-cmp
      cmp-nvim-lsp
      cmp-path
      cmp-buffer
      cmp-vsnip
      cmp-lua
      cmp-nvim-lsp-signature-help
      nvim-autopairs
      telescope-nvim
      nvim-lua
      nvim-tree-lua
      rust-tools-nvim
      kanagawa-nvim
    ];
    
    # Complex Lua configuration
    afterInit = ''
      -- Setup LSP capabilities
      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      
      -- Diagnostic signs from init.txt
      vim.fn.sign_define('DiagnosticSignError', {text = '', texthl = 'DiagnosticSignError'})
      vim.fn.sign_define('DiagnosticSignWarn', {text = '', texthl = 'DiagnosticSignWarn'})
      vim.fn.sign_define('DiagnosticSignHint', {text = '', texthl = 'DiagnosticSignHint'})
      vim.fn.sign_define('DiagnosticSignInfo', {text = '', texthl = 'DiagnosticSignInfo'})
      
      -- LSP configuration from init.txt
      require('lspconfig').rust_analyzer.setup({
        capabilities = capabilities,
      })
      require('lspconfig').nil_ls.setup({
        capabilities = capabilities,
      })
      
      -- Rust tools configuration from init.txt
      require('rust-tools').setup({
        server = {
          on_attach = function(_, bufnr)
            -- Hover actions
            vim.keymap.set("n", "<C-space>", require('rust-tools.hover_actions').hover_actions, { buffer = bufnr, silent = true })
            -- Code action groups
            vim.keymap.set("n", "<Leader>a", require('rust-tools.code_action_group').code_action_group, { buffer = bufnr, silent = true })
          end,
        },
      })
      
      -- Diagnostic configuration from init.txt
      vim.diagnostic.config({
        virtual_text = false,
        signs = true,
        update_in_insert = true,
        underline = true,
        severity_sort = false,
        float = {
          border = 'rounded',
          source = 'always',
          header = '',
          prefix = '',
        },
      })
      
      -- Completion configuration from init.txt
      local cmp = require'cmp'
      cmp.setup({
        -- Enable LSP snippets
        snippet = {
          expand = function(args)
            vim.fn["vsnip#anonymous"](args.body)
          end,
        },
        mapping = {
          ['<C-p>'] = cmp.mapping.select_prev_item(),
          ['<C-n>'] = cmp.mapping.select_next_item(),
          -- Add tab support
          ['<S-Tab>'] = cmp.mapping.select_prev_item(),
          ['<Tab>'] = cmp.mapping.select_next_item(),
          ['<C-S-f>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.close(),
          ['<CR>'] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Insert,
            select = true,
          })
        },
        -- Installed sources:
        sources = {
          { name = 'path' },
          { name = 'nvim_lsp', keyword_length = 3 },
          { name = 'nvim_lsp_signature_help'},
          { name = 'nvim_lua', keyword_length = 2},
          { name = 'buffer', keyword_length = 2 },
          { name = 'vsnip', keyword_length = 2 },
          { name = 'calc'},
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        formatting = {
          fields = {'menu', 'abbr', 'kind'},
          format = function(entry, item)
            local menu_icon ={
              nvim_lsp = 'λ',
              vsnip = '⋗',
              buffer = 'Ω',
              path = '🖫',
            }
            item.menu = menu_icon[entry.source.name]
            return item
          end,
        },
      })
      
      -- Treesitter configuration from init.txt
      require('nvim-treesitter.configs').setup {
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        indent = { enable = true }, 
        rainbow = {
          enable = true,
          extended_mode = true,
          max_file_lines = nil,
        },
      }
      
      -- Autocmd for Nix files from init.txt
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "nix",
        callback = function()
          vim.bo.tabstop = 2
          vim.bo.shiftwidth = 2
          vim.bo.softtabstop = 2
          vim.bo.expandtab = true
        end
      })
    '';
  };
}
