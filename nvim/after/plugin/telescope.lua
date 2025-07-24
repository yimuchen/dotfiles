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
  { '<leader>l',  group = '[L]SP' },
  { '<leader>la', lsp_action,         desc = '[L]SP [A]ction' },
  { '<leader>lr', vim.lsp.buf.rename, desc = '[L]SP [R]ename' },
}
