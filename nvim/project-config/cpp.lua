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
  require('conform').formatters_by_ft.cpp = {
    modexec.mod.conform_formatter('clang-format', {
      cmd_prefix = {'_cmsexec'},
      cmd_postfix = { '--style=file' },
    }),
  }
elseif vim.fn.executable 'clangd' ~= 0 then
  -- Vanilla setup of clangd exists
  require('lspconfig').clangd.setup {}
  require('conform').formatters_by_ft.cpp = { 'clang-format' }
end
