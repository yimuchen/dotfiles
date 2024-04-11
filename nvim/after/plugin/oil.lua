require('oil').setup { -- Adding the previous directory to be shown (easier for navigation)
  view_options = {
    is_hidden_file = function(name, bufnr)
      if name == '.' then
        return false
      end
      if name == '..' then
        return false
      end
      return vim.startswith(name, '.')
    end,
  },
}

-- Helper method to directly open items in preview mode

-- Temporary hack to open preview to the right
vim.opt.splitright = true
-- Setting up custom keymaps
vim.keymap.set('n', '<leader>pv', '<CMD>Oil ' .. vim.fn.getcwd() .. '<CR>', { desc = '[P]roject [V]iew' })
vim.keymap.set('n', '<leader>pm', '<CMD>Oil<CR>', { desc = '[P]roject [M]odify' })
