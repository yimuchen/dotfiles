-- Bootstrap with without lazy.nvim being explicitly installed
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

-- Packages to install will be define in the lazy directory
require('lazy').setup {
  spec = 'customize.lazy',
  change_detection = { notify = false },
}
