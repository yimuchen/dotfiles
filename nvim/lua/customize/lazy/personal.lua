local base_dir = vim.env.HOME .. '/.config/nvim-custom/plugins/'
local return_list = {}

local add_local_plugin = function(name, opt)
  if vim.loop.fs_stat(base_dir .. name) ~= nil then
    opt.dir = base_dir .. name
    table.insert(return_list, opt)
  end
end

-- For syncing the directory on save
add_local_plugin('rsync', {
  dependencies = { 'rcarriga/nvim-notify' },
  config = function()
    require('rsync').setup {}
  end,
})

-- For adding a REPL-like interaction in a accompanying tmux session's
-- dettachable pane
add_local_plugin('tmux-repl', {
  config = function()
    local repl = require 'tmux-repl'
    repl.setup {
      repl_start_cmd = function()
        local repl_root = vim.fs.root(0, '.repl.sh')
        if repl_root ~= 0 then
          return vim.fs.joinpath(repl_root, '.repl.sh')
        end
        return nil
      end,
    }

    local pass_selection = function(visual_sequence, post_execute)
      return function()
        vim.api.nvim_input(visual_sequence .. vim.g.mapleader .. 'rp')
        if post_execute ~= nil then
          repl.repl_send_line(post_execute)
        end
      end
    end

    local wk = require 'which-key'
    wk.add {
      { '<leader>r',   group = '[R]EPL' },
      { '<leader>rt',  repl.repl_pane_toggle,      desc = '[R]EPL [T]ermial' },
      { '<leader>rk',  repl.repl_pane_close,       desc = '[R]EPL [K]ill session' },
      { '<leader>rp',  repl.repl_pass_visual,      desc = '[R]EPL [P]ass selection',      mode = 'v' },
      -- Generic functions that can be used
      { '<leader>re',  group = '[R]EPL [E]valuate' },
      { '<leader>rel', pass_selection 'V',         desc = '[R]EPL [E]valuate [L]ine' },
      { '<leader>red', pass_selection 'ggVG',      desc = '[R]EPL [E]valuate [D]ocument' },
      { '<leader>ref', pass_selection 'vaF',       desc = '[R]EPL [E]valuate [F]function' },
      { '<leader>rec', pass_selection 'vaC',       desc = '[R]EPL [E]valuate [C]lass' },
    }
  end,
})

return return_list
