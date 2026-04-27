vim.pack.add({
  { src = 'https://github.com/saghen/blink.cmp', version = vim.version.range('v1.x') }, -- Main completion engine
  'https://github.com/L3MON4D3/LuaSnip'
})

require('blink.cmp').setup({
  keymap = { preset = 'default' },
  appearance = { nerd_font_variant = 'normal' },
  completion = { documentation = { auto_show = false } },
  sources = { default = { 'lsp', 'path', 'snippets', 'buffer' } },
  fuzzy = { implementation = "lua" }
})
