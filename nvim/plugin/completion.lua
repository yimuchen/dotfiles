vim.pack.add({
  'https://github.com/saghen/blink.cmp', -- Main completion engine
  'https://github.com/L3MON4D3/LuaSnip'
})

require('blink.cmp').setup({
  keymap = { preset = 'default' },
  appearance = { nerd_font_variant = 'normal' },
  completion = { documentation = { auto_show = false } },
  sources = { default = { 'lsp', 'path', 'snippets', 'buffer' } },
  fuzzy = { implementation = "lua" }
})
