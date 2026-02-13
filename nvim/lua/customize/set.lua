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

-- Displaying problematic whitespace characters
vim.opt.list = true
vim.opt.listchars = { tab = '▷ ', trail = '🮙', extends = '>', precedes = '<' }

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
vim.opt.foldmethod = 'expr' -- Folding using Tree-sitter syntax parser
vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
vim.opt.foldlevel = 20      -- Expand everything by default

-- Adding some additional key mappings for vim built-in functions
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
vim.opt.spell = false -- Disable by default, expecting that this is handled by LSP
vim.opt.spelloptions = 'camel'

-- Stop generating diagnostic updates when inserting (ltex-ls)
vim.diagnostic.config { update_in_insert = false }

-- Setting the shell to be using ZSH. For single-user neovim installs using
-- nix, this should be in $HOME/.nix-profile/bin; otherwise it would be in the
-- /etc/ profile directory
if vim.fn.isdirectory(vim.env.HOME .. '/.nix-profile/bin') ~= 0 then
  vim.opt.shell = vim.env.HOME .. '/.nix-profile/bin/zsh'
elseif vim.fn.isdirectory('/etc/profiles/per-user/' .. vim.env.USER) ~= 0 then
  vim.opt.shell = '/etc/profiles/per-user/' .. vim.env.USER .. '/bin/zsh'
elseif vim.fn.isdirectory(vim.env.HOME .. '/.portage') ~= 0 then
  vim.opt.shell = vim.env.HOME .. '/.portage/bin/zsh'
else
  vim.opt.shell = '/bin/zsh'
end

-- Adding global functions for LSPs to switch execution environments on
-- directory or path patterns
vim.g.get_prefixed_exec = function(exe_name)
  if vim.fn.isdirectory('/cvmfs/cms.cern.ch') ~= 0 and vim.fn.system("cmssw_src_path") ~= "" then
    -- Calling the tools installed in a CMSSW environment. These need to be
    -- defined in the custom scripts directory
    local mod_exec = vim.env.HOME .. "/.config/dot-bin/remote/cmssw/cmssw-" .. exe_name
    if vim.fn.filereadable(mod_exec) ~= 0 then
      return mod_exec
    else
      return exe_name
    end
  end

  if vim.env.CONDA_PREFIX ~= nil then
    -- For calling tools installed in a conda environment
    local mod_exec = vim.env.CONDA_PREFIX .. "/bin/" .. exe_name
    if vim.fn.filereadable(mod_exec) ~= 0 then
      return mod_exec
    end
  end

  if vim.fs.root(0, { ".apptainer-" .. exe_name }) ~= nil then
    -- For tool loaded in an apptainer environment, the project in question
    -- will need to provide the .apptainer-exe script for how the tool should
    -- be initialized with apptainer environment of interest
    return vim.fs.root(0, { ".apptainer-" .. exe_name }) .. "/.apptainer-" .. exe_name
  end
  return exe_name
end
