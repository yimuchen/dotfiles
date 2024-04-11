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
    ['<leader>ph'] = 'actions.show_help',
    ['<leader>psv'] = 'actions.select_vsplit',
    ['<leader>psh'] = 'actions.select_split',
    ['<leader>po'] = 'actions.preview',
    ['<leader>pc'] = 'actions.close',
    ['<leader>pr'] = 'actions.refresh',
    ['<leader>pp'] = 'actions.parent',
    ['<leader>pv'] = 'actions.open_cwd',
    -- ['`'] = 'actions.cd',
    -- ['~'] = 'actions.tcd',
    ['<leader>ps'] = 'actions.change_sort',
    -- ['gx'] = 'actions.open_external',
    ['<leader>pl'] = 'actions.toggle_hidden',
    ['<leader>pt'] = 'actions.toggle_trash',
    -- Hard selection functions
    ['<CR>'] = 'actions.select',
    ['<C-t>'] = 'actions.select_tab',
  },
  use_default_keymaps = false,
}

-- Temporary hack to open preview to the right. I don't usually open splits so
-- this is fine?
vim.opt.splitright = true
