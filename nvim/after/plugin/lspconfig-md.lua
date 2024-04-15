require('mason-lspconfig').setup { ensure_installed = { 'marksman' } }

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'markdown' },
  callback = function()
    require('lspconfig').marksman.setup {}
  end,
})

-- Formatting methods
require('conform').formatters_by_ft.markdown = { 'mdformat' }
