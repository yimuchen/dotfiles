-- Simple function for running a shell command and getting the stdout and stderr as strings to be processed

-- Helper function - getting the main executable script for custom tmux commands
local tmux_custom = vim.env.HOME .. '/.config/tmux/_tmux_custom.sh'

local get_tmux_session = function()
  if vim.env.TMUX == nil then
    vim.notify('The REPL terminal requires neovim to be ran within a tmux session', vim.log.levels.ERROR)
    return ''
  end
  -- Need to remove final substring
  return vim.fn.system({ 'tmux', 'display-message', '-p', '#S' }):sub(1, -2)
end

-- Getting the visual selections line by line, this solution was from a GitHub
-- comment for ToggleTerm REPL interactions:
-- https://github.com/akinsho/toggleterm.nvim/issues/425#issuecomment-1854373704
local _pass_visual_repl = function()
  -- visual markers only update after leaving visual mode
  local tmux_session = get_tmux_session()
  if tmux_session == '' then -- Early exist for invalid tmux session
    return
  end

  -- Open the repl pane if not already open
  vim.fn.system { tmux_custom, '_open_repl_pane', tmux_session }

  local esc = vim.api.nvim_replace_termcodes('<esc>', true, false, true)
  vim.api.nvim_feedkeys(esc, 'x', false)

  -- get selected text
  local start_line, start_col = unpack(vim.api.nvim_buf_get_mark(0, '<'))
  local end_line, end_col = unpack(vim.api.nvim_buf_get_mark(0, '>'))
  local lines = vim.fn.getline(start_line, end_line)

  local line_count = 0
  for _, line in ipairs(lines) do
    -- Skipping empty line
    if not line:match '^%s*$' then
      vim.fn.system {
        'tmux',
        'send-keys',
        '-t',
        tmux_session .. ':1.1',
        line,
        'Enter', -- Adding newline item
      }
      line_count = line_count + 1
    end
  end
  if line_count > 0 then -- Add final newline to ensure the item is executed
    vim.fn.system {
      'tmux',
      'send-keys',
      '-t',
      tmux_session .. ':1.1',
      'Enter', -- Adding newline item
    }
  end
end

local _toggle_repl = function()
  local tmux_session = get_tmux_session()
  if tmux_session == '' then
    return
  end
  vim.fn.system { tmux_custom, '_toggle_repl_pane', tmux_session }
end

local wk = require 'which-key'
wk.add {
  { '<leader>t', group = '[T]erminal' },
  { '<leader>tr', _toggle_repl, desc = '[T]erminal [R]EPL' },
  { '<leader>pr', _pass_visual_repl, desc = '[P]ass [R]EPL', mode = 'v' },
}
