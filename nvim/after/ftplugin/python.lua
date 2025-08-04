--- Settings specific to python
-- vim.lsp.enable('pylsp')
vim.lsp.enable('ruff')
vim.lsp.enable('pyrefly')

--- Adding multi-line strings to mini.ai
require('mini.ai').config.custom_textobjects['M'] = function()
  return { string.format('%s().-()%s', '"""\n', '\n *"""\n') }
end

-- Adding an explicit prefix to modify where python executable start
local cmd_prefix = ""
if vim.fn.executable('_cmssw_src_path') ~= 0 and vim.fn.system("_cmssw_src_path") ~= "" then
  vim.print(vim.fn.system('_cmssw_src_path'))
  cmd_prefix = vim.env.HOME .. "/.config/dot-bin/remote/cmssw/cmssw-"
elseif vim.env.CONDA_PREFIX ~= nil then
  cmd_prefix = vim.env.CONDA_PREFIX .. "/bin/"
elseif vim.fs.root(0, { ".apptainer-ruff" }) ~= nil then
  cmd_prefix = vim.fs.root(0, { ".apptainer-pylsp" }) .. "/.apptainer-"
end

local conform = require("conform")
local orig = require("conform.formatters.ruff_organize_imports")
conform.formatters.ruff_order = vim.deepcopy(orig)
conform.formatters.ruff_order.command = cmd_prefix .. conform.formatters.ruff_order.command
conform.formatters_by_ft["python"] = { "ruff_order" }


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
