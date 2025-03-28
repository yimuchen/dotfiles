-- Setting up python LSP methods
local modexec = require 'modexec'

-- The default settings would be to use ruff as a plugin for pylsp, this way
-- the formatting is also handled by the LSP where ever possible.
local pylsp_settings = {
  pylsp = {
    plugins = {
      ruff = {
        enabled = true,
        formatEnabled = true,
        format = { 'I' }, -- Attempt to sort imports if possible
        lineLength = 88, -- Default line, will be overwritten by anything in pyproject.toml or similar
      },
    },
  },
}

if modexec.current_config.cmssw ~= nil then
  local cmssw = modexec.current_config.cmssw
  modexec.mod.lsp_setup('pylsp', { cmd_prefix = cmssw.cmd_prefix, settings = pylsp_settings })

  -- Python formatting not setup in for CMSSW for now
elseif modexec.current_config.conda ~= nil then
  local conda_mod = modexec.current_config.conda

  local lsp_mod = vim.deepcopy(conda_mod)
  lsp_mod.settings = pylsp_settings
  modexec.mod.lsp_setup('pylsp', pylsp_settings)

  require('conform').formatters_by_ft['python'] = {
    modexec.mod.conform_formatter('ruff_format', conda_mod),
    modexec.mod.conform_formatter('ruff_organize_imports', conda_mod),
  }
elseif modexec.current_config.apptainer ~= nil then
  local apptainer = modexec.current_config.apptainer
  local lsp_config = {
    cmd_prefix = apptainer.cmd_prefix,
    root_dir = function(_)
      return apptainer.cmd_base
    end,
    settings = pylsp_settings,
  }
  modexec.mod.lsp_setup('pylsp', lsp_config)
  local conform_config = {
    cmd_prefix = apptainer.cmd_prefix,
    cwd = function(_)
      return apptainer.cmd_base
    end,
  }
  require('conform').formatters_by_ft['python'] = {
    modexec.mod.conform_formatter('ruff_format', conform_config),
    modexec.mod.conform_formatter('ruff_organize_imports', conform_config),
  }
else
  -- Setting up the python LSP and formatting methods
  if vim.fn.executable 'pylsp' ~= 0 then
    require('lspconfig').pylsp.setup { settings = pylsp_settings }
  end
end
