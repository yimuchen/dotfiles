-- Mason will not be used for the various installation, as black, flake8 and
-- isort is are plugins not registered under mason.
require('lspconfig').pylsp.setup {
  settings = {
    pylsp = {
      plugins = {
        -- Use flake8 instead of pycodestyle
        flake8 = { enabled = true },
        pycodestyle = { enabled = false },
        -- Default formatting
        black = { enabled = true },
        isort = { enable = true },
      },
    },
  },
}

-- Formatting methods
require('conform').formatters_by_ft.python = { 'isort', 'black' }

-- Additional surrounding function
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'python',
  callback = function()
    require('mini.ai').config.custom_textobjects['M'] = function()
      --- Triple quote /excluding new lines
      return { string.format('%s().-()%s', '"""\n', '\n *"""\n') }
    end
  end,
})

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
