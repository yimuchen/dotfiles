local lsp = require("lsp-zero")
require("mason-lspconfig").setup({
  ensure_installed = { "tsserver" },
  handlers = { lsp.default_setup },
})

-- Use the prettier formatter by default
require('mason-tool-installer').setup({
  ensure_installed = { 'prettierd', },
  auto_update = false,
  run_on_start = false,
})

-- Additional injections using null-ls
local null_ls = require("null-ls");
null_ls.setup({ sources = { null_ls.builtins.formatting.prettier }, })
