-- Defining the texlab settings
if vim.fn.executable 'texlab' then
  require('lspconfig').texlab.setup {} -- Default setup for texlab
end
-- if vim.fn.executable 'ltex-ls' then
--   require('lspconfig').ltex.setup {}
-- end

-- Formatting methods
require('conform').formatters_by_ft.tex = { 'latexindent' }
