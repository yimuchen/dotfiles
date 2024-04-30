return { -- Fuzzy finder telescope
  'nvim-telescope/telescope.nvim',
  branch = '0.1.x',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope-ui-select.nvim',
    'nvim-tree/nvim-web-devicons',
    'nvim-telescope/telescope-fzf-native.nvim',
  },
  config = function()
    local telescope = require 'telescope'
    local ts_builtin = require 'telescope.builtin'
    telescope.setup {}

    -- Adding additional telescope plugins
    pcall(telescope.load_extension, 'fzf')
    pcall(telescope.load_extension, 'ui-select')

    -- Setting up the key bindings
    vim.keymap.set('n', '<leader>sf', ts_builtin.find_files, { desc = '[S]earch [F]ile' })
    vim.keymap.set('n', '<leader>st', ts_builtin.git_files, { desc = '[S]earch git-[T]racked' })
    vim.keymap.set('n', '<leader>sh', ts_builtin.help_tags, { desc = '[S]earch [H]elp' })
    vim.keymap.set('n', '<leader>sk', ts_builtin.keymaps, { desc = '[S]earch [K]eymaps' })
    vim.keymap.set('n', '<leader>sw', ts_builtin.grep_string, { desc = '[S]earch current [W]ord' })
    vim.keymap.set('n', '<leader>sg', ts_builtin.live_grep, { desc = '[S]earch by [G]rep' })
    vim.keymap.set('n', '<leader>sd', ts_builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
    vim.keymap.set('n', '<leader>sr', ts_builtin.resume, { desc = '[S]earch [R]esume' })
    vim.keymap.set('n', '<leader>s.', ts_builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
    vim.keymap.set('n', '<leader>sb', ts_builtin.buffers, { desc = '[S]earch [B]uffers' })
  end,
}
