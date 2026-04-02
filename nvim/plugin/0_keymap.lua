-- While most plugin groups will have their configuration be managed within
-- their file, which-key will always need to be loaded in first, as this is how
-- we define keybinds in other files
vim.pack.add({ 'https://github.com/folke/which-key.nvim' })
local wk = require('which-key')
wk.setup({ preset = 'helix' })
wk.add({
  {
    '<leader>?',
    function()
      require('which-key').show { global = true }
    end,
    desc = 'Keymaps explorer',
  },
  { 'g',                group = 'Goto' },
  -- Common aliases for starting the command prompt with exiting prefixes
  { '<leader>x',        ':lua ',                          desc = 'Starting lua executor' },
  { '<leader>c',        ':! ',                            desc = 'Starting command executor' },
  { '<leader><leader>', function() vim.cmd("source") end, desc = "Reload configuration" },
  -- Moving selection up and down
  -- Stolen from theprimeagen: https://github.com/ThePrimeagen/init.lua/blob/master/lua/theprimeagen/remap.lua
  { "K",                ":m '<-2<CR>gv=gv",               desc = 'Move selection up',           mode = 'v' },
  { 'J',                ":m '>+1<CR>gv=gv",               desc = 'Move selection down',         mode = 'v' },
  -- Pasting from the system clipboard
  { "<leader>p",        [["_dP]],                         desc = "Paste from system clipboard", mode = 'x' }

})
