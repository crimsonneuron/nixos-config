-- plugins.lua

-- Colourscheme
require("kanagawa").setup({})
vim.cmd.colorscheme("kanagawa")

-- Treesitter
require("nvim-treesitter.configs").setup({
  -- Grammars are bundled by Nix (withAllGrammars), so auto_install is off
  auto_install = false,
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  indent = {
    enable = true,
  },
  rainbow = {
    enable = true,
    extended_mode = true,
    max_file_lines = nil,
  },
})

-- Telescope
require("telescope").setup({})

-- Autopairs
require("nvim-autopairs").setup({})

-- Surround
require("nvim-surround").setup({})

-- Conjure is zero-config by default; add overrides here if needed
-- require("conjure")  -- loads itself via ftplugin

-- rustaceanvim is also zero-config; add overrides via vim.g.rustaceanvim if needed
-- e.g.:
-- vim.g.rustaceanvim = {
--   server = { capabilities = require("cmp_nvim_lsp").default_capabilities() },
-- }
