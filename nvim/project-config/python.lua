-- Setting up python LSP methods
local lspconfig = require 'lspconfig'
if vim.g._project_cmssw_path ~= nil then
  vim.g._lsp_setup('pylsp', { cmd_prefix = {'_cmsexec'} })
  vim.g._lsp_setup('ruff', { cmd_prefix = {'_cmsexec'} })
  -- Do *not* setup python formatting here
else
  -- Setting up the python LSP and formatting methods
  if vim.fn.executable 'pylsp' ~= 0 then
    require('lspconfig').pylsp.setup {}
  end

  if vim.fn.executable 'ruff' ~= 0 then
    -- Using ruff-lsp as a the primary language server for linting. This should
    -- be made available in your language configurations.
    require('lspconfig').ruff.setup {}
    require('conform').formatters_by_ft.python = { 'ruff_format', 'ruff_organize_imports' }
  end
end
-- Formatting methods
