if vim.fn.executable 'pylsp' ~= 0 then
  -- pylsp will be used for context aware language server
  require('lspconfig').pylsp.setup {}
end

if vim.fn.executable 'ruff' ~= 0 then
  -- Using ruff-lsp as a the primary language server for linting. This should
  -- be made available in your language configurations.
  require('lspconfig').ruff.setup {}
end

-- Formatting methods
require('conform').formatters_by_ft.python = { 'ruff_format', 'ruff_organize_imports' }

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
-- Additional settings for notebook and REPL setup setups
--
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'markdown', -- Only working on markdown file that is converted from notebook files
  callback = function()
    -- vim.notify 'This is a message'
    local buffer_name = vim.api.nvim_buf_get_name(0)
    vim.print('Checking file name' .. string.sub(buffer_name, -6) .. '[.ipynb]')
    if string.sub(buffer_name, -6) ~= '.ipynb' then
      return -- Early exit if it is not a notebook file
    end

    -- Embedded language displays
    -- languages / completion / diagnostics / treesitter query
    require('otter').activate({ 'python' }, true, true, nil)
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
