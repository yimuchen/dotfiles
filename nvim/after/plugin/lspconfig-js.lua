-- LSP related setups
require('lspconfig').svelte.setup {}
require('lspconfig').cssls.setup {}

-- Formatting set
local conform = require 'conform'

-- Setting the prettier to detect the pretteir install the node environment
conform.formatters.prettier = {
  command = 'npx',
  args = { 'prettier', '--stdin-filepath', '$FILENAME' },
}
conform.formatters_by_ft.svelte = { 'prettier' }
conform.formatters_by_ft.css = { 'prettier' }
conform.formatters_by_ft.javascript = { 'prettier' }
conform.formatters_by_ft.html = { 'prettier' }
