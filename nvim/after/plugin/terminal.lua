-- Setting up new methods and keybinding to split a interactive terminal to the
-- right hand side of the item
local term_buf = nil
local term_win = nil

function TermToggle(width)
  if term_win and vim.api.nvim_win_is_valid(term_win) then
    vim.cmd [[hide]]
  else
    vim.cmd [[vertical new]]
    local new_buf = vim.api.nvim_get_current_buf()
    vim.cmd('vertical resize ' .. width)
    if term_buf and vim.api.nvim_buf_is_valid(term_buf) then
      vim.cmd('buffer ' .. term_buf) -- go to terminal buffer
      vim.cmd('bd ' .. new_buf) -- cleanup new buffer
    else
      vim.cmd 'terminal'
      term_buf = vim.api.nvim_get_current_buf()
      vim.wo.number = false
      vim.wo.relativenumber = false
      vim.wo.signcolumn = 'no'
    end
    vim.cmd [[startinsert!]]
    term_win = vim.api.nvim_get_current_win()
  end
end

-- Adding keybindings via which key
local wk = require 'which-key'

wk.add {
  { '<leader>tt', ':lua TermToggle(80)<CR>', mode = 'n', desc = 'Toggle terminal' },
  { '<leader>tt', '<C-\\><C-n>:lua TermToggle(80)<CR>', mode = 't', desc = 'Toggle terminal' },
  { '<Esc>', '<C-\\><C-n>', mode = 't', desc = 'Exit terminal mode' },
}
