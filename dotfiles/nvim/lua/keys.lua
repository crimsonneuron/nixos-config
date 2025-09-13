--[[ keys.lua ]]
local map = vim.api.nvim_set_keymap

-- remap the key used to leave insert mode
-- In your keys.lua or init.lua
vim.keymap.set('i', 'jk', '<Esc>', { noremap = true, silent = true })

-- Toggle nvim-tree
map('n', 'ff', [[:Telescope find_files]], {})
