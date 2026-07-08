-- plugins.lua

-- Colourscheme
require("kanagawa").setup({})
vim.cmd.colorscheme("kanagawa")

-- Treesitter
-- New main-branch API: setup() only configures install behaviour now.
-- Grammars are bundled by Nix, so there's nothing to install.
require("nvim-treesitter").setup({
  install_dir = vim.fn.stdpath("data") .. "/site",
})

-- Highlighting and indent are no longer auto-enabled by the plugin;
-- turn them on yourself per-buffer.
vim.api.nvim_create_autocmd("FileType", {
  callback = function()
    -- pcall guards filetypes with no parser available
    pcall(vim.treesitter.start)
    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
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
