-- Boot strapwith without lazy.nvim being explciitly installed
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

-- Listing packages to install
require('lazy').setup {
  'folke/lazy.nvim', -- Having lazy manage itself

  { -- Fuzzy finder telescope
    'nvim-telescope/telescope.nvim',
    tag = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope-ui-select.nvim',
      'nvim-tree/nvim-web-devicons',
      'nvim-telescope/telescope-fzf-native.nvim',
    },
  },
  -- Treesitter for syntax highlighting
  { 'nvim-treesitter/nvim-treesitter', build = ':TSUpdate' },

  -- LSP zero and language related plugins
  { 'VonHeikemen/lsp-zero.nvim', branch = 'v3.x' },
  { 'neovim/nvim-lspconfig' },
  { 'williamboman/mason.nvim' }, -- Engine for managing external dependencies
  { 'williamboman/mason-lspconfig.nvim' },
  { 'WhoIsSethDaniel/mason-tool-installer.nvim' }, -- Formatter and linting tool installation
  { 'stevearc/conform.nvim' }, -- Formatting engine
  { -- For auto completion
    'hrsh7th/nvim-cmp',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      { -- Snippet engine for writing custom snippets
        'L3MON4D3/LuaSnip',
        version = 'v2.*',
        build = 'make install_jsregexp',
      },
      'saadparwaiz1/cmp_luasnip',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
    },
  },
  { -- For buffer-based file system navigation
    'stevearc/oil.nvim',
    opts = {},
    -- Optional dependencies
    dependencies = { 'nvim-tree/nvim-web-devicons' },
  },

  --
  -- A bunch of nice eye candy !
  --
  { 'loctvl842/monokai-pro.nvim' }, -- Monokai color scheme
  { 'nvim-lualine/lualine.nvim', dependencies = { 'nvim-tree/nvim-web-devicons' } }, -- Nice status lines
  { 'lukas-reineke/indent-blankline.nvim', main = 'ibl', opts = {} }, -- indent guides
  { -- Comment highlighter for notes and to-dos
    'folke/todo-comments.nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = { signs = false },
  },
  { -- Breadcrumb for feature signature
    'utilyre/barbecue.nvim',
    name = 'barbecue',
    version = '*',
    dependencies = { 'SmiteshP/nvim-navic', 'nvim-tree/nvim-web-devicons' },
    opts = {},
  },

  { 'ThePrimeagen/vim-be-good' }, -- For VIM motion training
  { 'mbbill/undotree' }, -- TODO: Learn to how to effectively use undotree!!
  { 'tpope/vim-fugitive' }, -- TODO: Learn how to effectivley use git in nvim

  -- Notebook editing in VIM / TODO: Try and make this work better?
  { 'GCBallesteros/jupytext.nvim', config = true },
}
