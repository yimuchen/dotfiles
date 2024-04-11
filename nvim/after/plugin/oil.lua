require('oil').setup { -- Adding the previous directory to be shown (easier for navigation)
  view_options = {
    is_hidden_file = function(name, bufnr)
      if name == '..' then
        return false
      end
      return vim.startswith(name, '.')
    end,
  },
  keymaps = {
    -- ['`'] = 'actions.cd',
    -- ['~'] = 'actions.tcd',
    -- Hard selection functions
    ['<CR>'] = 'actions.select',
    ['<C-t>'] = 'actions.select_tab',
  },
  use_default_keymaps = false,
}

-- Temporary hack to open preview to the right. I don't usually open splits so
-- this is fine?
vim.opt.splitright = true

local actions = require 'oil.actions'

local register = function(keys, method, desc)
  vim.keymap.set('n', '<leader>' .. keys, method.callback, { desc = desc, buffer = 0 })
end

-- Helpers that can be used at all levels
vim.keymap.set('n', '<leader>bv', actions.open_cwd.callback, { desc = '[B]rowser [V]iew' })
vim.keymap.set('n', '<leader>bh', actions.show_help.callback, { desc = '[B]rowser [H]elp' })
vim.keymap.set('n', '<leader>bm', require('oil').open, { desc = '[B]rowser [M]odify buffer directory' })

vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWinEnter' }, {
  pattern = { 'oil://*' },
  callback = function()
    -- Functions that only make sense for oil buffers
    register('bsv', actions.select_vsplit, '[B]rowser [S]plit [V]ertical')
    register('bsh', actions.select_split, '[B]rowser [S]plit [H]orizontal')
    register('bp', actions.preview, '[B]rowser [P]review')
    register('bc', actions.close, '[B]rowser [C]lose')
    register('br', actions.refresh, '[B]rowser [R]efresh')
    register('bu', actions.parent, '[B]rowser move [U]p')
    register('bth', actions.toggle_hidden, '[B]rowser [T]oggle [H]idden')
    register('btt', actions.toggle_trash, '[B]rowser [T]oggle [T]rash')
    register('bts', actions.change_sort, '[B]rowser [T]ogger [S]ort')
    register('bx', actions.open_external, '[B]rowser e[X]ternal')
    -- Additional mapping used for closing browser
    vim.keymap.set('n', '<C-c>', actions.close.callback, { desc = 'Close Browser' })

    -- Starting in preview by default, this doesn't work...
    -- actions.preview.callback()
  end,
})
