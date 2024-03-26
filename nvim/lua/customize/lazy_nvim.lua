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

  -- Monokai color scheme
  {
    'loctvl842/monokai-pro.nvim',
    config = function()
      require('monokai-pro').setup()
    end,
  },
  {
    'folke/todo-comments.nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = { signs = false },
  },

  -- Lua line settings
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
  },

  -- Treesitter
  { 'nvim-treesitter/nvim-treesitter', build = ':TSUpdate' },
  { 'mbbill/undotree' },
  { 'tpope/vim-fugitive' },

  -- LSP zero and language related plugins
  { 'VonHeikemen/lsp-zero.nvim', branch = 'v3.x' },
  { 'neovim/nvim-lspconfig' },
  { 'nvimtools/none-ls.nvim' }, -- For additional formatting methods
  { 'williamboman/mason.nvim' }, -- Engine for managing external dependencies
  { 'williamboman/mason-lspconfig.nvim' },
  { 'WhoIsSethDaniel/mason-tool-installer.nvim' }, -- Formatter and linting tool installation
  -- For auto completion
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      { -- Snippet engine for writing custom snippeds
        'L3MON4D3/LuaSnip',
        version = 'v2.*',
        build = 'make in stall_jsregexp',
      },
      'saadparwaiz1/cmp_luasnip',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
    },
  },
  -- Formatting engine
  { 'stevearc/conform.nvim' },

  -- For VIM motion training
  { 'ThePrimeagen/vim-be-good' },

  -- Notebook editing in VIM
  { 'GCBallesteros/jupytext.nvim', config = true },
}
  -- Snippet engine
