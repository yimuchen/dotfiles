if vim.fn.executable 'lua-language-server' then
  require('lspconfig').lua_ls.setup {}
end
require('conform').formatters_by_ft.lua = { 'stylua' }
