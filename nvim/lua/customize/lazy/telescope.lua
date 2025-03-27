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
    telescope.setup {
      defaults = {
        file_ignore_patterns = {
          -- Node related packages
          'node_modules/*',
          -- Python related directories
          '__pycache__/*',
          'site-packages/*',
          -- Commonly used data/image/non-text files that will likely be dumped
          -- in the work spaces similar to the code files
          -- '**/*.root', # This is not needed and causes things to break??
          '**/*.pdf',
          '**/*.png',
        },
      },
    }

    -- Adding additional telescope plugins
    pcall(telescope.load_extension, 'fzf')
    pcall(telescope.load_extension, 'ui-select')
    -- Setting up the key bindings (with which-key)
    local wk = require 'which-key'
    wk.add {
      { '<leader>s', group = 'search', mode = 'n', icon = '' },
      { '<leader>sf', ts_builtin.find_files, desc = '[S]earch [F]ile', icon = '' },
      { '<leader>st', ts_builtin.git_files, desc = '[S]earch git-[T]racked', icon = '' },
      { '<leader>sh', ts_builtin.help_tags, desc = '[S]earch [H]elp', icon = '' },
      { '<leader>sw', ts_builtin.grep_string, desc = '[S]earch current [W]ord' },
      { '<leader>sg', ts_builtin.live_grep, desc = '[S]earch by [G]rep' },
      { '<leader>sr', ts_builtin.resume, desc = '[S]earch [R]esume' },
      { '<leader>s.', ts_builtin.oldfiles, desc = '[S]earch Recent Files ("." for repeat)' },
      { '<leader>sb', ts_builtin.buffers, desc = '[S]earch [B]uffers' },
      -- Search key maps is handled by telescope (for all key maps without explicit description )
      { '<leader>sk', ts_builtin.keymaps, desc = '[S]earch [K]eymaps', icon = '' },
    }
  end,
}
