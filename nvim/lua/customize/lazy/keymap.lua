return {
  'folke/which-key.nvim',
  event = 'VeryLazy',
  opts = { preset = 'helix' },
  keys = {
    -- Setting up the which-key specific keybinding and multi-argument
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
    { 'J',                ":m '>+1<CR>gv=gv",               desc = 'Move selection down',         mode = 'v' },
    { "K",                ":m '<-2<CR>gv=gv",               desc = 'Move selection up',           mode = 'v' },
    -- Pasting from the system clipboard
    { "<leader>p",        [["_dP]],                         desc = "Paste from system clipboard", mode = 'x' }
  },
}
