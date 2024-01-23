-- Boot strapwith without lazy.nvim being explciitly installed
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- Listing packages to install
require("lazy").setup({
	-- Having lazy manage itself
	"folke/lazy.nvim",

	-- Fuzzy finder telescope
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.5",
		dependencies = { "nvim-lua/plenary.nvim" },
	},

	-- Monokai color scheme
	{
		"loctvl842/monokai-pro.nvim",
		config = function()
			require("monokai-pro").setup()
		end,
	},
	-- Lua line settings
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
	},

	-- Treesitter
	{ "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
	"mbbill/undotree",
	"tpope/vim-fugitive",

	-- LSP zero and language related plugins
	{ "VonHeikemen/lsp-zero.nvim", branch = "v3.x" },
	{ "neovim/nvim-lspconfig" },
	{ "williamboman/mason.nvim" }, -- Engine for managing external dependencies
	{ "williamboman/mason-lspconfig.nvim" },
	{ "WhoIsSethDaniel/mason-tool-installer.nvim" }, -- Formatter and linting tool installation
	{ "hrsh7th/nvim-cmp" }, -- For auto completion
	{ "hrsh7th/cmp-nvim-lsp" },
	{ "mhartington/formatter.nvim" }, -- Engine for calling external formatters
	{ -- Snippet engine
		"L3MON4D3/LuaSnip",
		version = "v2.*",
		build = "make install_jsregexp",
	},
	{ "saadparwaiz1/cmp_luasnip" },

	-- For training
	{ "ThePrimeagen/vim-be-good" },

	-- Notebook editing in VIM
	-- use({ "GCBallesteros/jupytext.nvim", config = true })
})
