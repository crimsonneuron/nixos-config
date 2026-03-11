-- autocmds.lua

-- Show diagnostics float on cursor hold
vim.api.nvim_create_autocmd("CursorHold", {
  callback = function()
    vim.diagnostic.open_float(nil, { focusable = false })
  end,
})

-- JSON conceal
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "json", "jsonc" },
  callback = function()
    vim.opt_local.concealcursor = "nvic"
  end,
})

-- 2-space indent for Nix
vim.api.nvim_create_autocmd("FileType", {
  pattern = "nix",
  callback = function()
    vim.bo.tabstop     = 2
    vim.bo.shiftwidth  = 2
    vim.bo.softtabstop = 2
    vim.bo.expandtab   = true
  end,
})

-- 2-space indent for QML
vim.api.nvim_create_autocmd("FileType", {
  pattern = "qml",
  callback = function()
    vim.bo.tabstop     = 2
    vim.bo.shiftwidth  = 2
    vim.bo.softtabstop = 2
    vim.bo.expandtab   = true
  end,
})

-- Diagnostic signs
local function sign(name, text)
  vim.fn.sign_define(name, { texthl = name, text = text, numhl = "" })
end

sign("DiagnosticSignError", "🔥")
sign("DiagnosticSignWarn",  "⚠️")
sign("DiagnosticSignHint",  "💡")
sign("DiagnosticSignInfo",  "ℹ️")

-- Diagnostic display config
vim.diagnostic.config({
  virtual_text    = false,
  signs           = true,
  update_in_insert = true,
  underline       = true,
  severity_sort   = false,
  float = {
    border = "rounded",
    source = "always",
    header = "",
    prefix = "",
  },
})
