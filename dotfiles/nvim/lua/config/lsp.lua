-- lsp.lua

local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- nil_ls: Nix LSP
vim.lsp.config("nil_ls", {capabilities=capabilities,})
vim.lsp.enable("nil_ls")

vim.lsp.config("ocamllsp" , {capabilities=capabilities,})
vim.lsp.enable("nil_ls")
-- rustaceanvim sets up rust-analyzer on its own via its plugin;
-- do NOT call lspconfig.rust_analyzer.setup() here.
