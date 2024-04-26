local conform = require 'conform'

require('conform').formatters.prettier = {
  command = 'npx',
  args = { 'prettier', '$FILENAME' },
}
-- Svelte flavor
require('lspconfig').svelte.setup {}
require('conform').formatters_by_ft.svelte = { 'prettier' }

-- CSS flavor
require('lspconfig').cssls.setup {}
conform.formatters_by_ft.css = { 'prettier' }

-- JS formatter
conform.formatters_by_ft.javascript = { 'prettier' }
