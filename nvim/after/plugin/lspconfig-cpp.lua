if vim.fn.executable 'clangd' then
  require('lspconfig').clangd.setup {}
end
require('conform').formatters_by_ft.cpp = { 'clang-format' }
