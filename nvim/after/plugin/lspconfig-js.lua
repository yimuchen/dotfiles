-- LSP related setups
require('lspconfig').svelte.setup {}
require('lspconfig').cssls.setup {}

-- Formatting set
local conform = require 'conform'

-- Setting the prettier to detect the pretteir install the node environment
conform.formatters.npx_prettier = {
  command = 'npx',
  args = { 'prettier', '--stdin-filepath', '$FILENAME' },
}
conform.formatters_by_ft.html = { 'npx_prettier' }
conform.formatters_by_ft.css = { 'npx_prettier' }
conform.formatters_by_ft.javascript = { 'npx_prettier' }
conform.formatters_by_ft.svelte = { 'npx_prettier' }
