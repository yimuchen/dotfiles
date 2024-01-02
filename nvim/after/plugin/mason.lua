-- Setting up the external packages to be handled by mason
local lsp_zero = require("lsp-zero")

require("mason").setup({})

-- Listing LSP to use always keep installed
require("mason-lspconfig").setup({
	ensure_installed = { -- List of LSP to use by default
		"pylsp", -- Python LSP, Nicer than jedi as it also supports flake8
		"clangd", -- C++
		"ltex", -- tex/latex (with spell checking for markdown as well
		-- Any additional server you might want added
		"tsserver",
		"rust_analyzer",
	},
	-- No additional handlers are required for now
	handlers = {
		lsp_zero.default_setup,
		lua_ls = function()
			local lua_opts = lsp_zero.nvim_lua_ls()
			require("lspconfig").lua_ls.setup(lua_opts)
		end,
	},
})

-- Required tools for linting and formatting, only keep the LSPs to be handled by mason-lspconfig
require('mason-tool-installer').setup {
  ensure_installed = {
    'stylua', -- Lua styling 
    'shfmt', -- Shell formatting 
    'clang-format', -- C/C++ formatting
    'latexindent', -- Latex formatting
    'codespell', -- Spell checking in variable name and comments
  },
  auto_update = false,
  run_on_start = false,
  debounce_hours = 5, -- at least 5 hours between attempts to install/update
}
