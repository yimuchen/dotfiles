-- Setting up the LSP for shell script writing
local lsp = require 'lsp-zero'

-- Addtional tools that you might want installed
require('mason-lspconfig').setup {
  ensure_installed = { 'bashls' },
  handlers = { lsp.default_setup },
}
require('mason-tool-installer').setup {
  ensure_installed = { 'shfmt' },
}

-- Additional methods for formatting (Use spaces rather than tabs)
local conform = require 'conform'
conform.formatters.shfmt = {
  prepend_args = function()
    return { '-i', '3' }
  end,
}
conform.formatters_by_ft.sh = { 'shfmt' }
