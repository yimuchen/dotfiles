-- COMMON GLOBAL SETTINGS

-- Using the default fat cursor
vim.opt.guicursor = ''

-- Left bar numbering
vim.opt.nu = true
vim.opt.relativenumber = true

-- Default tab in nothing is set
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true

-- Displaying problematic white space characters
vim.opt.list = true
vim.opt.listchars = { tab = '▷ ', trail = '▨', extends = '>', precedes = '<' }

-- Do not attempt to wrap the text on display
vim.opt.wrap = false

-- Back up information
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv 'HOME' .. '/.nvim/undodir'
vim.opt.undofile = true

-- Some additional search setting
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.opt.signcolumn = 'yes'
vim.opt.isfname:append '@-@'

-- Fast time interval
vim.opt.updatetime = 50

-- Set the warning column
vim.opt.colorcolumn = '120'

-- Setting the folding expression
vim.opt.foldmethod = 'expr' -- Folding using tree-sitter syntax parser
vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
vim.opt.foldlevel = 20 -- Expand everything by default

-- Adding some additional key mappings for vim in-built functions
vim.g.mapleader = ' ' -- leader key for custom mapping

-- Highlighting text on yank
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Setting the spelling checking for single words
vim.opt.spelllang = 'en_us'
vim.opt.spell = true
vim.opt.spelloptions = 'camel'

-- Stop generating diagnostic updates when inserting (ltex-ls)
vim.diagnostic.config { update_in_insert = false }
