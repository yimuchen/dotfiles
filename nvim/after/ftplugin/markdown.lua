-- vim.notify 'This is a message'
local buffer_name = vim.api.nvim_buf_get_name(0)
if string.sub(buffer_name, -6) == '.ipynb' then
  -- Embedded language displays
  -- languages / completion / diagnostics / treesitter query
  require('otter').activate({ 'python' }, true, true, nil)
end
