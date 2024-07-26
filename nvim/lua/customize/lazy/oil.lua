return {
  -- For buffer-based file system navigation
  'stevearc/oil.nvim',
  opts = {},
  -- Optional dependencies
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    require('oil').setup { -- Adding the previous directory to be shown (easier for navigation)
      view_options = {
        is_hidden_file = function(name, __bufnr)
          if name == '..' then
            return false
          end
          return vim.startswith(name, '.')
        end,
      },
      keymaps = {},
      use_default_keymaps = false,
    }

    -- Temporary hack to open preview to the right. I don't usually open splits so
    -- this is fine?
    vim.opt.splitright = true

    -- Setting up the key maps. Split to outside the setup method to ensure a
    -- consistent documentation
    local wk = require 'which-key'
    local actions = require 'oil.actions'
    wk.add {
      { '<leader>B', actions.open_cwd.callback, desc = '[B]rowser (current working director)' },
      { '<leader>b', require('oil').open, desc = '[B]rowser (Buffer directory)' },
    }

    vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWinEnter' }, {
      pattern = { 'oil://*' },
      callback = function()
        -- Functions for modifying the Oil inspection buffer
        wk.add {
          { '<C-p>', actions.preview.callback, desc = '[P]review' },
          { '<C-c>', actions.close.callback, desc = '[C]lose' },
          { '<CR>', actions.select.callback, desc = 'Select line' },
          { '<C-t>', actions.select_tab.callback, desc = 'Select in [T]ab' },
          { '<C-x>', actions.open_external.callback, desc = 'Open with e[X]ternal program' },
          { '<C-u>', actions.parent.callback, desc = 'Move [U]p' },
          { '<C-h>', actions.toggle_hidden.callback, desc = 'Toggle [H]idden' },
          { '<F5>', actions.refresh.callback, desc = 'Refresh' },
          { '<F6>', actions.change_sort.callback, desc = 'Toggle Sort' },
        }
      end,
    })
  end,
}
