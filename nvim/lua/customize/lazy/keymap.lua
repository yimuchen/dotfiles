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
    { 'g', group = 'Goto' },
    -- Common aliases for starting the command prompt with exiting prefixes
    { '<leader>x', ':lua ', desc='Starting lua executor' },
    { '<leader>c', ':! ', desc='Starting command executor' },
  },
}
