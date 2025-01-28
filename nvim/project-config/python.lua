-- Setting up python LSP methods
local modexec = require 'modexec'

if modexec.current_config.cmssw ~= nil then
  local cmssw = modexec.current_config.cmssw
  modexec.mod.lsp_setup('pylsp', { cmd_prefix = cmssw.cmd_prefix })
  modexec.mod.lsp_setup('ruff', { cmd_prefix = cmssw.cmd_prefix })

  -- Python formatting not setup in for CMSSW for now
elseif modexec.current_config.apptainer ~= nil then
  local apptainer = modexec.current_config.apptainer
  local lsp_config = {
    cmd_prefix = apptainer.cmd_prefix,
    root_dir = function(_)
      return apptainer.cmd_base
    end,
  }
  modexec.mod.lsp_setup('pylsp', lsp_config)
  modexec.mod.lsp_setup('ruff', lsp_config)
  local conform_config = {
    cmd_prefix = apptainer.cmd_prefix,
    cwd = function(_)
      return apptainer.cmd_base
    end,
  }
  require('conform').formatters_by_ft.python = {
    modexec.mod.conform_formatter('ruff_format', conform_config),
    modexec.mod.conform_formatter('ruff_organize_imports', conform_config),
  }
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
