-- keymaps.lua

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Escape shortcuts
map("i", "jk", "<Esc>", opts)
map("x", "jk", "<Esc>", opts)

-- Telescope (non-leader)
map("n", "ff", ":Telescope find_files<CR>", opts)

-- Telescope (leader)
map("n", "<leader>ff", "<cmd>Telescope find_files<CR>",  opts)
map("n", "<leader>fg", "<cmd>Telescope live_grep<CR>",   opts)
map("n", "<leader>fb", "<cmd>Telescope buffers<CR>",     opts)
map("n", "<leader>fh", "<cmd>Telescope help_tags<CR>",   opts)
