-- COMMON GLOBAL SETTINGS

-- Using the default fat cursor
vim.opt.guicursor = ""

-- Left var numbering
vim.opt.nu = true
vim.opt.relativenumber = true

-- Default tab in nothing is set
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true

-- Displaying problematic whitespace characters
vim.opt.list = true
vim.opt.listchars = { tab = "▷ ", trail = "▨", extends = ">", precedes = "<" }

-- Do not attemp to wrap the text on display, use main instead
vim.opt.wrap = false

-- Back up information
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.nvim/undodir"
vim.opt.undofile = true

-- Some additional search setting
vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

-- Fast time interval
vim.opt.updatetime = 50

-- Set the warning column
vim.opt.colorcolumn = "120"

-- Setting the folding expression
vim.opt.foldmethod = "expr" -- Folding using treesitter syntax parser
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldlevel = 20      -- Expand everything by default

-- Additional file type association
vim.filetype.add({
	extension = {
		service = "cfg",
	},
	filename = {
		["zshrc"] = "sh",
		["sshconfig"] = "sshconfig",
		--["/etc/foo/config"] = "toml",
	},
})

-- Highlighting text on yank
vim.api.nvim_create_autocmd('TextYankPost', {
	desc = 'Highlight when yanking (copying) text',
	group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})
