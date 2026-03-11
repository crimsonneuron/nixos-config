-- lsp.lua

local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- nil_ls: Nix LSP
lspconfig.nil_ls.setup({
  capabilities = capabilities,
})

-- rustaceanvim sets up rust-analyzer on its own via its plugin;
-- do NOT call lspconfig.rust_analyzer.setup() here.
