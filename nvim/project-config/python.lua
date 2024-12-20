-- Setting up python LSP methods
if vim.g._project_lsp_opt_default ~= nil then
  vim.g._lsp_setup('pylsp', vim.g._project_lsp_opt_default)
  vim.g._lsp_setup('ruff', vim.g._project_lsp_opt_default)
  if vim.g._project_cmssw_path == nil then
    -- Only setup formatting is not in CMSSW environment
    require('conform').formatters_by_ft.python = {
      vim.g._conform_setup('ruff_format', vim.g._project_fmt_opt_default),
      vim.g._conform_setup('ruff_organize_imports', vim.g._project_fmt_opt_default),
    }
  end
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
