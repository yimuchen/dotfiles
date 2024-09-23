return {
  -- Helper for spawning a terminal within nvim for simple code correctness
  -- checking
  'akinsho/toggleterm.nvim',
  version = '*',
  config = function()
    -- Default settings for requiring the default settings
    require('toggleterm').setup {
      direction = 'vertical', -- Split to the right
      size = function(term)
        if term.direction == 'horizontal' then
          return 10 -- Small, shallow terminal
        elseif term.direction == 'vertical' then
          return vim.o.columns * 0.4
        else
          return 20
        end
      end,
      winbar = { -- Disable supposed winbar
        enabled = false,
        name_formatter = function(term) --  term: Terminal
          return term.name
        end,
      },
    }
    -- Disable spell checking for terminal environments
    vim.api.nvim_create_autocmd('TermEnter', {
      pattern = 'term://*toggleterm#*',
      callback = function()
        vim.opt.spell = false
      end,
    })

    -- Creating the singular global objects that can be used to create a
    -- terminal instance. The terminal will be created on the first call of the
    -- toggle command, you can override the settings be resetting the global
    -- variables either in the project `.nvim` directory, or when starting nvim
    -- before spawning in any terminal window. We assume that you will only be
    -- using the nvim terminal for direct code interaction, so we only allow a
    -- singular terminal to be present.
    --
    -- For options, see:
    -- https://github.com/akinsho/toggleterm.nvim?tab=readme-ov-file#custom-terminals
    local _term = require('toggleterm.terminal').Terminal
    _REPL_TERM_INST = nil --global instance of the terminal
    vim.g.repl_term_config = { hidden = true, name = 'repl_term' }

    local _toggle_repl = function()
      if _REPL_TERM_INST == nil then
        _REPL_TERM_INST = _term:new(vim.g.repl_term_config)
      end
      _REPL_TERM_INST:toggle()
    end

    -- Function for ensuring that we can copy visual selections to the terminal
    -- with blank lines in the edit buffer Full credit for this solution is
    -- given can be found here:
    -- https://github.com/akinsho/toggleterm.nvim/issues/425#issuecomment-1854373704
    local _pass_visual_repl = function()
      -- visual markers only update after leaving visual mode
      local esc = vim.api.nvim_replace_termcodes('<esc>', true, false, true)
      vim.api.nvim_feedkeys(esc, 'x', false)

      -- get selected text
      local start_line, start_col = unpack(vim.api.nvim_buf_get_mark(0, '<'))
      local end_line, end_col = unpack(vim.api.nvim_buf_get_mark(0, '>'))
      local lines = vim.fn.getline(start_line, end_line)

      -- send selection with trimmed indent
      local cmd = ''
      local indent = nil
      for _, line in ipairs(lines) do
        if indent == nil and line:find '[^%s]' ~= nil then
          indent = line:find '[^%s]'
        end
        -- (i)python interpreter evaluates sent code on empty lines -> remove
        if not line:match '^%s*$' then
          cmd = cmd .. line:sub(indent or 1) .. string.char(13) -- trim indent
        end
      end
      require('toggleterm').exec(cmd, _REPL_TERM_INST.id)
    end

    -- Setting additional key binding with which key
    local wk = require 'which-key'
    wk.add {
      { '<leader>t', group = '[T]erminal' },
      { '<leader>tr', _toggle_repl, desc = '[T]erminal [R]EPL' },
      { '<leader>pr', _pass_visual_repl, desc = '[P]ass [R]EPL', mode = 'v' },
      -- Getting the old key binding for entering normal mode back
      { '<Esc>', '<C-\\><C-n>', mode = 't', desc = 'Exit terminal mode' },
    }
  end,
}
