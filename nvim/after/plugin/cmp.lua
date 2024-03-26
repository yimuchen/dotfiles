-- Main package to configure
local cmp = require 'cmp'

-- Packages that require configuration
local lsp_zero = require 'lsp-zero'
-- local lsnip = require("luasnip")

local cmp_select = { behavior = cmp.SelectBehavior.Select }
local cmp_action = lsp_zero.cmp_action()

local luasnip = require 'luasnip'
luasnip.config.setup {}

cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },

  sources = {
    { name = 'path' },
    { name = 'nvim_lsp' },
    { name = 'nvim_lua' },
    { name = 'luasnip' },
  },
  formatting = lsp_zero.cmp_format(),
  mapping = cmp.mapping.preset.insert {
    ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
    ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
    ['<C-y>'] = cmp.mapping.confirm { select = true },
    ['<C-space>'] = cmp.mapping.complete {},
  },
}
