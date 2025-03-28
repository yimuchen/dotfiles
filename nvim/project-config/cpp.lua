-- Setting the LSP, linters and formatters for CPP and python files to point to the
-- executable in the container/internal CMSSW environment instead
local modexec = require 'modexec'

if modexec.current_config.cmssw ~= nil then
  -- Clangd configurations
  local cmssw_path = modexec.current_config.cmssw.cmd_base
  modexec.mod.lsp_setup('clangd', {
    cmd_prefix = {'_cmsexec'},
    cmd_postfix = { '--compile-commands-dir=' .. cmssw_path .. '/../' },
    root_dir = function()
      return cmssw_path
    end,
  })
elseif vim.fn.executable 'clangd' ~= 0 then
  -- Vanilla setup of clangd exists
  require('lspconfig').clangd.setup {}
end
