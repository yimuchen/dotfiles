-- Setting up the external packages to be handled by mason
require('lspconfig').lua_ls.setup({})
require('conform').formatters_by_ft.lua = { 'stylua' }
