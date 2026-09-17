-- options.lua

vim.g.mapleader      = "\\"
vim.g.localleader    = ","
vim.g.t_co           = 256
vim.g.background     = "dark"

local opt = vim.opt

-- Context
opt.colorcolumn    = "80"
opt.number         = true
opt.relativenumber = true
opt.scrolloff      = 4
opt.signcolumn     = "yes"

-- Filetypes
opt.encoding     = "utf8"
opt.fileencoding = "utf8"

-- Theme
opt.termguicolors = true
opt.background    = "dark"

-- Search
opt.ignorecase = true
opt.smartcase  = true
opt.incsearch  = true
opt.hlsearch   = false

-- Whitespace
opt.expandtab   = true
opt.shiftwidth  = 2
opt.softtabstop = 2
opt.tabstop     = 2

-- Splits
opt.splitright = true
opt.splitbelow = true

-- Completion
opt.completeopt = { "menuone", "noselect", "noinsert" }
opt.updatetime  = 300

-- Folding (treesitter-based)
opt.foldmethod    = "expr"
opt.foldexpr      = "nvim_treesitter#foldexpr()"
opt.foldlevel     = 999
opt.foldlevelstart = 999

-- Misc
opt.shortmess:append({ c = true })
