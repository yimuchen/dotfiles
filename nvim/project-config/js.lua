-- LSP related setups
if vim.fn.executable 'svelteserver' then
  require('lspconfig').svelte.setup {}
end
if vim.fn.executable 'vscode-css-language-server' then
  require('lspconfig').cssls.setup {}
end
-- Formatting set
local conform = require 'conform'

-- Setting the prettier to detect the prettier install the node environment
conform.formatters.npx_prettier = {
  command = 'npx',
  args = { 'prettier', '--stdin-filepath', '$FILENAME' },
}
conform.formatters_by_ft.html = { 'npx_prettier' }
conform.formatters_by_ft.css = { 'npx_prettier' }
conform.formatters_by_ft.javascript = { 'npx_prettier' }
conform.formatters_by_ft.svelte = { 'npx_prettier' }

-- Setting a separate parser for JSON using JQ (which is always available for nix-based installs)
conform.formatters_by_ft.json = { 'jq' }
