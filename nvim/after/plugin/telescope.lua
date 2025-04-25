local ts_builtin = require 'telescope.builtin'
local ts_themes = require 'telescope.themes'


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
  { '<leader>a',  group = '[A]ction' },
  { '<leader>af', lsp_action,         desc = '[A]ction LSP [F]ix' },
  { '<leader>ar', vim.lsp.buf.rename, desc = '[A]ction [R]ename' },
}
