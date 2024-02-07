local lsp = require("lsp-zero")

-- LSP related mappings definitions
lsp.on_attach(function(client, bufnr)
  local opts = { buffer = bufnr, remap = false }

  vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
  -- vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
  -- vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
  -- vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
  vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
  vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
  vim.keymap.set("n", "<leader>ds", function() vim.diagnostic.open_float() end, opts)
  -- vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
  -- vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
  -- vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
  -- vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
  vim.keymap.set("n", "<leader>ff", function() vim.lsp.buf.format() end, opts)
end)


require('mason').setup({})
-- LSP installs are handled using mason-lspconfig.
-- For the set of Languages that are handled by default, consider constructing
-- the corresponding lspconfig.<language>.lua file for detailed handling of how
-- the language server behaves.
require("mason-lspconfig").setup({
  ensure_installed = { -- List of LSP to use by default
    -- "pylsp",        Python LSP, As third party plugins are required, This is handled by the OS/virtualenv
    "clangd",          -- C++
    "ltex",            -- tex/latex (with spell checking for markdown as well
    "lua_ls",          -- Lua (For neovim configuration)
    -- Any additional server you might want added
    "tsserver",
    "rust_analyzer",
  },
  -- No additional handlers are required for now
  handlers = {
    lsp.default_setup,
  },
})

-- Addtional tools that you might want installed
require('mason-tool-installer').setup {
  ensure_installed = {
    'shfmt',        -- Shell formatting
    'clang-format', -- C/C++ formatting
    'latexindent',  -- Latex formatting
    'codespell',    -- Spell checking in variable name and comments
  },
  auto_update = false,
  run_on_start = false,
  debounce_hours = 5, -- at least 5 hours between attempts to install/update
}
