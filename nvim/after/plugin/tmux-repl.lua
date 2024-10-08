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

local _send_line_to_repl = function(line)
  local tmux_session = get_tmux_session()
  if tmux_session == '' then -- Early exist for invalid tmux session
    return
  end
  vim.fn.system { tmux_custom, '_open_repl_pane', tmux_session }
  vim.fn.system {
    'tmux',
    'send-keys',
    '-t',
    tmux_session .. ':1.1',
    line,
    'Enter', -- Adding newline item
  }
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
  local indent = nil
  for _, line in ipairs(lines) do
    if indent == nil and line:find '[^%s]' ~= nil then
      indent = line:find '[^%s]'
    end
    -- Skipping empty line
    if not line:match '^%s*$' then
      _send_line_to_repl(line:sub(indent or 1))
    end
  end
  if line_count > 0 then -- Add final newline to ensure the item is executed
    _send_line_to_repl 'Enter'
  end
end

local _toggle_repl = function()
  local tmux_session = get_tmux_session()
  if tmux_session == '' then
    return
  end
  vim.fn.system { tmux_custom, '_toggle_repl_pane', tmux_session }
end

local _execute_nvim_input = function(input)
  return function()
    vim.api.nvim_input(input)
  end
end

local _execute_repl_input = function(input)
  return function()
    _send_line_to_repl(input)
  end
end

local wk = require 'which-key'
wk.add {
  { '<leader>r', group = '[R]EPL' },
  { '<leader>rt', _toggle_repl, desc = '[R]EPL [T]ermial' },
  { '<leader>rp', _pass_visual_repl, desc = '[R]EPL [P]ass selection', mode = 'v' },
  -- Generic functions that can be used
  { '<leader>red', _execute_nvim_input 'ggVG rp', desc = '[R]EPL [E]valuate [D]ocument' },
  {
    '<leader>ref',
    function() -- Requires an extra new line to be executed?
      _execute_nvim_input 'vaF rp'()
      _execute_repl_input 'Enter' ()
    end,
    desc = '[R]EPL [E]valuate [F]unction',
  },
  { '<leader>rec', _execute_nvim_input 'vaC rp', desc = '[R]EPL [E]valuate [C]lass' },
  { '<leader>rel', _execute_nvim_input 'V rp', desc = '[R]EPL [E]valuate [L]ine' },
}

-- Specific function required for python-based repl
-- TODO not working??
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'python',
  callback = function()
    wk.add {
      {
        '<leader>rr',
        function()
          _execute_repl_input '%reset'()
          _execute_repl_input 'y'()
        end,
        desc = '[R]EPL [R]eload',
      },
      {
        '<leader>rc',
        function()
          _execute_repl_input 'clear'()
          _toggle_repl()
          _toggle_repl()
        end,
        desc = '[R]EPL [C]lear',
      },
    }
  end,
})
