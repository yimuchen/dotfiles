local ts_builtin = require 'telescope.builtin'
local ts_themes = require 'telescope.themes'

local spell_suggest = function()
  ts_builtin.spell_suggest(ts_themes.get_cursor {
    prompt_title = 'spelling suggestions',
    layout_config = {
      height = 0.25,
      width = 0.25,
    },
  })
end

local lsp_action = function()
  vim.lsp.buf.code_action(ts_themes.get_cursor {
    prompt_title = 'LSP suggestions',
    layout_config = {
      height = 0.25,
      width = 0.25,
    },
  })
end

local wk = require 'which-key'
wk.add {
  -- Actions to perform on the specific item variable
  { '<leader>a', group = '[A]ction' },
  { '<leader>as', spell_suggest, desc = '[A]ction [S]pell sugggestion', icon = '' },
  { '<leader>af', lsp_action, desc = '[A]ction LSP [F]ix' },
}
