-- lsp.lua

local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- nil_ls: Nix LSP
vim.lsp.config("nil_ls", {capabilities=capabilities,})
vim.lsp.enable("nil_ls")

vim.lsp.config("ocamllsp" , {capabilities=capabilities,})
vim.lsp.enable("ocamllsp")

vim.g.loaded_coqtail = 1
vim.g["coqtail#supported"] = 0

-- Rocq/Coq files aren't recognized by default (clashes with Verilog's .v)
vim.filetype.add({ extension = { v = "coq" } })

require("coq-lsp").setup({
  lsp = {
    on_attach = function(client, bufnr)
      local opts = { buffer = bufnr, silent = true }
      vim.keymap.set("n", "<localleader>g", "<Cmd>CoqLsp open_info_panel<CR>", opts)
    end,
  },
})

-- rustaceanvim sets up rust-analyzer on its own via its plugin;
-- do NOT call lspconfig.rust_analyzer.setup() here.
