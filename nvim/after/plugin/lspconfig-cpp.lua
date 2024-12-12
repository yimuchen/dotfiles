if vim.fn.executable 'clangd' then
  require('lspconfig').clangd.setup {}
  require('conform').formatters_by_ft.cpp = { 'clang-format' }
end
