vim.pack.add({
  "https://github.com/ibhagwan/fzf-lua",
  'https://github.com/stevearc/oil.nvim' -- For buffer based file operations
})
local fzf = require("fzf-lua")
-- -- Setting up the default theme
fzf.setup({ "telescope" })
local wk = require("which-key")
wk.add({
  { '<leader>s', group = 'search', mode = 'n', icon = '' },
  { '<leader>sf', fzf.files, desc = '[S]earch [F]ile', icon = '' },
  { '<leader>st', fzf.git_files, desc = '[S]earch git-[T]racked', icon = '' },
  { '<leader>sh', fzf.help_tags, desc = '[S]earch [H]elp', icon = '' },
  { '<leader>sw', fzf.grep_cword, desc = '[S]earch current [W]ord' },
  { '<leader>sg', fzf.live_grep, desc = '[S]earch current [W]ord' },
  { '<leader>sk', fzf.keymaps, desc = '[S]earch [K]eymaps', icon = '' },
})

require('oil').setup({ -- Adding the previous directory to be shown (easier for navigation)
  view_options = {
    is_hidden_file = function(name, _)
      if name == '..' then
        return false
      end
      return vim.startswith(name, '.')
    end,
  },
  keymaps = {},
  use_default_keymaps = false,
})

-- Temporary hack to open preview to the right. I don't usually open splits so
-- this is fine?
vim.opt.splitright = true

-- Setting up the keymaps. Split to outside the setup method to ensure a
-- consistent documentation
local actions = require 'oil.actions'
wk.add {
  { '<leader>B', actions.open_cwd.callback, desc = '[B]rowser (current working director)' },
  { '<leader>b', require('oil').open,       desc = '[B]rowser (Buffer directory)' },
}

vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWinEnter' }, {
  pattern = { 'oil://*' },
  callback = function()
    vim.treesitter.stop()
    -- Functions for modifying the Oil inspection buffer
    wk.add {
      { '<C-p>', actions.preview.callback,       desc = '[P]review' },
      { '<C-c>', actions.close.callback,         desc = '[C]lose' },
      { '<CR>',  actions.select.callback,        desc = 'Select line' },
      { '<C-t>', actions.select_tab.callback,    desc = 'Select in [T]ab' },
      { '<C-x>', actions.open_external.callback, desc = 'Open with e[X]ternal program' },
      { '<C-u>', actions.parent.callback,        desc = 'Move [U]p' },
      { '<C-h>', actions.toggle_hidden.callback, desc = 'Toggle [H]idden' },
      { '<F5>',  actions.refresh.callback,       desc = 'Refresh' },
      { '<F6>',  actions.change_sort.callback,   desc = 'Toggle Sort' },
    }
  end,
})
