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
  -- Having lazy manage itself
  'folke/lazy.nvim',

  -- Fuzzy finder telescope
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope-ui-select.nvim',
      'nvim-tree/nvim-web-devicons',
      'nvim-telescope/telescope-fzf-native.nvim',
    },
  },

  { -- Monokai color scheme
    'loctvl842/monokai-pro.nvim',
    config = function()
      require('monokai-pro').setup()
    end,
  },
  { -- Comment highlighter for notes and to-dos
    'folke/todo-comments.nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = { signs = false },
  },

  { -- Nice status lines
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
  },

  -- Treesitter for syntax highlighting
  { 'nvim-treesitter/nvim-treesitter', build = ':TSUpdate' },
  { 'mbbill/undotree' }, -- TODO: Learn to how to effectively use undotree!!
  { 'tpope/vim-fugitive' }, -- TODO: Learn how to effectivley use git in nvim

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
        build = 'make in stall_jsregexp',
      },
      'saadparwaiz1/cmp_luasnip',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
    },
  },

  { 'ThePrimeagen/vim-be-good' }, -- For VIM motion training

  { -- For syncing local edits to remote paths
    'OscarCreator/rsync.nvim',
    build = 'make',
    dependencies = 'nvim-lua/plenary.nvim',
  },

  -- Notebook editing in VIM / TODO: Try and make this work better?
  { 'GCBallesteros/jupytext.nvim', config = true },
}
