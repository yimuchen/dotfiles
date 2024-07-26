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
  },
}
