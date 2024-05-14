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

-- Special case for svelte, as neovim detects this as an embeded language and
-- will try and inject ';' characters in in-line svelte-js code
conform.formatters_by_ft.svelte = { 'npx_prettier' }

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'svelte' },
  callback = function()
    vim.keymap.set('n', '<leader>fb', function()
      conform.format { async = true, formatters = { 'npx_prettier', 'trim_whitespace' } }
    end, { desc = '[F]ormat selected [B]uffer' })
  end,
})
