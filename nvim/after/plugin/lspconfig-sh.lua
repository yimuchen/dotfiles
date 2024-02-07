-- Setting up the LSP for shell script writing
local lsp = require('lsp-zero')

-- Addtional tools that you might want installed
require("mason-lspconfig").setup({
  ensure_installed = { 'bashls' },
  handlers = { lsp.default_setup, },
})
require('mason-tool-installer').setup({
  ensure_installed = { 'shfmt' },
})

-- Additional methods for formatting (Use spaces rather than tabs)
local null_ls = require("null-ls")
local helper = require("null-ls.helpers")
local methods = require("null-ls.methods")
local FORMATTING = methods.internal.FORMATTING

local custom_shfmt = helper.make_builtin({
  name = "shfmt",
  meta = {
    url = "https://github.com/mvdan/sh",
    description = "A shell parser, formatter, and interpreter with `bash` support.",
  },
  method = FORMATTING,
  filetypes = { "sh" },
  generator_opts = {
    command = "shfmt",
    args = { "-filename", "$FILENAME", "-i", "3" },
    to_stdin = true,
  },
  factory = helper.formatter_factory,
})
null_ls.register(custom_shfmt)
