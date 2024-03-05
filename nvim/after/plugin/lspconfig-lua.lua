-- Setting up the external packages to be handled by mason
local lsp_zero = require("lsp-zero")
require("mason-lspconfig").setup({
	ensure_installed = { "lua_ls" },
	handlers = { lsp_zero.default_setup },
})

require("lspconfig").lua_ls.setup(lsp_zero.nvim_lua_ls())
require("conform").formatters_by_ft.lua = { "stylua" }
