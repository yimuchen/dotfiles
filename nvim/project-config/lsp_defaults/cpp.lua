if vim.fn.executable 'clangd' ~= 0 then
  -- require('lspconfig').clangd.setup {}
  require('conform').formatters_by_ft.cpp = { 'clang-format' }
end
