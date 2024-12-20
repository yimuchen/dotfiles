-- Setting the LSP, linters and formatters for CPP and python files to point to the
-- executable in the container/internal CMSSW environment instead
local cmssw_path = vim.g._project_cmssw_path
local lspconfig = require 'lspconfig'
local conform = require 'conform'

if cmssw_path ~= nil then
  -- Clangd configurations
  vim.g._lsp_setup('clangd', {
    cmd_prefix = { '_cmsexec' },
    cmd_postfix = { '--compile-commands-dir=' .. cmssw_path .. '/../' },
    root_dir = cmssw_path,
  })
  vim.g._conform_setup('clang-format', {
    cmd_prefix = { '_cmsexec' },
    cmd_postfix = { '--style=file' },
    filetype = { 'cpp' },
  })
elseif vim.fn.executable 'clangd' ~= 0 then
  -- Vanilla setup of clangd exists
  require('lspconfig').clangd.setup {}
  require('conform').formatters_by_ft.cpp = { 'clang-format' }
end
