-- Utilities for creating configurations
local util = require("formatter.util")
local fmtft = require("formatter.filetypes")
local remove_ws = fmtft.any.remove_trailing_whitespace

-- Custom method for automatically determining formatting based on git
-- repository settings (this allows for nested git projects to handle styling
-- differently if needed)
local find_format_config = function(expected_name)
	local git_path = vim.fn.finddir(".git", ".;")
	if git_path == "" then
		return ""
	else
		return vim.fn.findfile(expected_name, git_path .. "/../")
	end
end

-- Just for debugging, you should probably not use this
vim.api.nvim_create_user_command("FindFormatConfig", function(opts)
	local res = find_format_config(opts.fargs[1])
	print(type(res), res)
	print(vim.fn.expand("%"))
end, { nargs = 1 })

-- Provides the Format, FormatWrite, FormatLock, and FormatWriteLock commands
require("formatter").setup({
	-- Enable or disable logging
	logging = true,
	-- Set the log level
	log_level = vim.log.levels.WARN,
	-- All formatter configurations are opt-in
	filetype = {
		python = {
			function() -- Using YAPF is a style file is found. Otherwise use black
				local yapf_config = find_format_config(".style.yapf")
				if yapf_config ~= "" then
					return util.withl(fmtft.python.yapf, "--style=" .. yapf_config)()
				end
				return fmtft.python.black()
			end,
			fmtft.python.isort,
			remove_ws,
		},
		cpp = {
			function()
				local uncrusitfy_config = find_format_config(".uncrustify.conf")
				local clangfmt_config = find_format_config(".clang-format")

				-- Hot fixes required for CLANG
				local clangfmt_default = vim.fn.expand("$HOME/.config/nvim/external/clang-format")

				if uncrusitfy_config ~= "" then
					print("Formatting with uncrustify with configutation file: ", uncrusitfy_config)
					return util.withl(fmtft.cpp.uncrusitfy, "-c", uncrusitfy_config)()
				elseif clangfmt_config ~= "" then
					print("Formatting with clang-format with configuration file: ", clangfmt_config)
					return {
						exe = "clang-format",
						args = {
							"-style=file:" .. clangfmt_config,
							vim.fn.expand("%"),
						},
						stdin = true,
						try_node_modules = true,
					}
				else
					print("Formatting with clang-format with default configuration file:", clangfmt_default)
					return {
						exe = "clang-format",
						args = {
							"-style=file:" .. clangfmt_default,
							vim.fn.expand("%"),
						},
						stdin = true,
						try_node_modules = true,
					}
				end
			end,
			remove_ws,
		},
		sh = { fmtft.sh.shfmt, remove_ws }, -- Usually there is less issues with shell script formatting??
		tex = {
			function()
				local indent_config = find_format_config(".latexindent.yaml")
				local indent_default = vim.fn.expand("$HOME/.config/nvim/external/indentconfig.yaml")
				if indent_config ~= "" then
					return util.withl(fmtft.latex.latexindent, "--local=" .. indent_config)()
				end
				return util.withl(fmtft.latex.latexindent, "--local=" .. indent_default)()
			end,
			remove_ws,
		},
		json = { fmtft.json.prettier, remove_ws },
		markdown = { fmtft.markdown.prettier },

		-- Not a primary language, mainly for neovim setup
		lua = {
			-- "formatter.filetypes.lua" defines default configurations for the
			-- "lua" filetype
			require("formatter.filetypes.lua").stylua,

			-- You can also define your own configuration
			function()
				-- Supports conditional formatting
				if util.get_current_buffer_file_name() == "special.lua" then
					return nil
				end

				-- Full specification of configurations is down below and in Vim help
				-- files
				return {
					exe = "stylua",
					args = {
						"--search-parent-directories",
						"--stdin-filepath",
						util.escape_path(util.get_current_buffer_file_path()),
						"--",
						"-",
					},
					stdin = true,
				}
			end,
			remove_ws,
		},

		["*"] = { remove_ws }, --Default files that are not yet defined
	},
})

-- Setting up the key settings for formatting
vim.keymap.set("n", "<leader>ff", vim.cmd.Format) -- Format entire file
