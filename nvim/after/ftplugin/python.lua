--- Settings specific to python
vim.lsp.enable('pylsp')
vim.lsp.enable('ruff')


--- Adding multiline strings to mini.ai
require('mini.ai').config.custom_textobjects['M'] = function()
  return { string.format('%s().-()%s', '"""\n', '\n *"""\n') }
end

--
-- Snippets
--
local ls = require 'luasnip'
--local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
--local f = ls.function_node
--local c = ls.choice_node
--local d = ls.dynamic_node
--local r = ls.restore_node

ls.add_snippets('python', {
  -- trigger is `fn`, second argument to snippet-constructor are the nodes to
  -- insert into the buffer on expansion.
  ls.snippet('__main__', {
    t { 'if __name__ == "__main__":', '    ' },
    i(0),
  }),
})
