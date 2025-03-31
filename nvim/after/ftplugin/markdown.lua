-- Setting up the formatter
local conform = require("conform")
conform.formatters['py_mdformat'] = {
  command = vim.env.HOME .. "/.cli-python/bin/mdformat",
  args = {
    "--wrap=" .. vim.opt.colorcolumn._value,
    "--end-of-line=keep",
    "-" },
}
conform.formatters_by_ft['markdown'] = { 'py_mdformat' }


local buffer_name = vim.api.nvim_buf_get_name(0)
if string.sub(buffer_name, -6) == '.ipynb' then
  -- Embedded language displays
  -- languages / completion / diagnostics / treesitter query
  require('otter').activate({ 'python' }, true, true, nil)
end

vim.opt.wrap = true
