-- cmp.lua

local cmp     = require("cmp")
local luasnip = require("luasnip")

local menu_icons = {
  nvim_lsp = "λ",
  luasnip  = "⋗",
  buffer   = "Ω",
  path     = "🖫",
  nvim_lua = "🌙",
  calc     = "=",
}

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },

  mapping = cmp.mapping.preset.insert({
    ["<C-p>"]   = cmp.mapping.select_prev_item(),
    ["<C-n>"]   = cmp.mapping.select_next_item(),
    ["<S-Tab>"] = cmp.mapping.select_prev_item(),
    ["<Tab>"]   = cmp.mapping.select_next_item(),
    ["<C-S-f>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"]   = cmp.mapping.scroll_docs(4),
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-e>"]   = cmp.mapping.close(),
    ["<CR>"]    = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Insert,
      select   = true,
    }),
  }),

  sources = cmp.config.sources({
    { name = "nvim_lsp", keyword_length = 3 },
    { name = "luasnip",  keyword_length = 2 },
    { name = "path" },
    { name = "buffer",   keyword_length = 2 },
    { name = "nvim_lua", keyword_length = 2 },
    { name = "calc" },
  }),

  window = {
    completion    = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },

  formatting = {
    fields = { "menu", "abbr", "kind" },
    format = function(entry, item)
      item.menu = menu_icons[entry.source.name] or ""
      return item
    end,
  },
})
