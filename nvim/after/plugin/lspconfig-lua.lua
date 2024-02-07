-- Setting up the external packages to be handled by mason
local lsp_zero = require("lsp-zero")

require("lspconfig").lua_ls.setup(lsp_zero.nvim_lua_ls())
