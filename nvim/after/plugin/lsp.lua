local lsp = require("lsp-zero")

-- LSP related mappings definitions
lsp.on_attach(function(client, bufnr)
  local opts = { buffer = bufnr, remap = false }

  vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
  -- vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
  -- vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
  vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
  vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
  vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
  -- vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
  -- vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
  -- vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
  -- vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
  vim.keymap.set("n", "<leader>ff", function() vim.lsp.buf.format() end, opts)
end)

-- Individual language server set ups
--
-- For more complicated setup splitting the installation and configurations to
-- the a separate lspconfig-<language>.lau file for simpler management
require('mason').setup({})
require("mason-lspconfig").setup({
  ensure_installed = { -- List of LSP to use by default
    "clangd",          -- C++
    "ltex",            -- tex/latex (with spell checking for markdown as well
    -- Any additional server you might want added
    "tsserver",
    "rust_analyzer",
  },
  -- No additional handlers are required for now
  handlers = { lsp.default_setup },
})

-- Addtional tools that you might want installed
require('mason-tool-installer').setup {
  ensure_installed = {
    'clang-format', -- C/C++ formatting
    'latexindent',  -- Latex formatting
    'codespell',    -- Spell checking in variable name and comments
    -- TS formatting and
    'prettierd',
  },
  auto_update = false,
  run_on_start = false,
  debounce_hours = 5, -- at least 5 hours between attempts to install/update
}

-- Additional injections using null-ls
local null_ls = require("null-ls");
null_ls.setup({
  sources = {
    null_ls.builtins.formatting.prettier,
    null_ls.builtins.diagnostics.eslint,
  },
})
