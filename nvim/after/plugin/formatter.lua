-- Utilities for creating configurations
local fmt = require("formatter")
local util = require("formatter.util")
local fmtft = require("formatter.filetypes")
local remove_ws = fmtft.any.remove_trailing_whitespace

-- Provides the Format, FormatWrite, FormatLock, and FormatWriteLock commands
fmt.setup({
	-- Enable or disable logging
	logging = true,
	-- Set the log level
	log_level = vim.log.levels.WARN,
	-- All formatter configurations are opt-in
	filetype = {
		python = { fmtft.python.black, fmtft.python.isort, remove_ws },
		cpp = { fmtft.cpp.clangformat, remove_ws },
		sh = { fmtft.sh.shfmt, remove_ws },
		tex = { fmtft.latex.latexindent, remove_ws },
		json = { fmtft.json.prettier, remove_ws },
		markdown = { fmtft.markdown.prettier },

		-- Not a primary language, mainly for neovim setup
		lua = { fmtft.lua.stylua, remove_ws },

		["*"] = { remove_ws }, --Default files that are not yet defined
	},
})

-- Using mason to make sure the formatters are properly install
require("mason").setup({
	ensure_installed = { -- List of LSP to use by default
		--Python
		"black",
		"isort", --Nicer than jedi as it also supports flake8
		-- C++
		"clangformat",
		-- tex/latex
		"latexindent",

		--Lua
		"stylua",

		-- Markdown , javascript and JSON files
		"prettier",
	},
})

-- Setting up the key settings for formatting
vim.keymap.set("n", "<leader>ff", vim.cmd.Format) -- Format entire file
