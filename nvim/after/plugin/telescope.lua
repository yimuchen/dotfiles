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

local wk = require 'which-key'
wk.add {
  -- Actions to perform on the specific item variable
  { '<leader>a', group = '[A]lter' },
  { '<leader>as', spell_suggest, desc = '[A]ction [S]pell sugggestion', icon = '' },
}
