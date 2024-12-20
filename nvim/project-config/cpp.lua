-- Setting the LSP, linters and formatters for CPP and python files to point to the
-- executable in the container/internal CMSSW environment instead
local cmssw_path = vim.g._project_cmssw_path

if vim.g._project_lsp_opt_default ~= nil then
  -- Clangd configurations
  if cmssw_path ~= nil then
    local lsp_config = vim.deepcopy(vim.g._project_lsp_opt_default)
    lsp_config.cmd_postfix = { '--compile-commands-dir=' .. cmssw_path .. '/../' }
    lsp_config.root_dir = function(_)
      return cmssw_path
    end
    vim.g._lsp_setup('clangd', lsp_config)
    local fmt_config = vim.deepcopy(vim.g._project_fmt_opt_default)
    fmt_config.cmd_postfix = { '--style=file' }
    require('conform').formatters_by_ft.cpp = {
      vim.g._conform_setup('clang-format', fmt_config),
    }
  else
    vim.g._lsp_setup('clangd', vim.g._project_lsp_opt_default)
    require('conform').formatters_by_ft.cpp = {
      vim.g._conform_setup('clang-format', vim.g._project_fmt_opt_default),
    }
  end
elseif vim.fn.executable 'clangd' ~= 0 then
  -- Vanilla setup of clangd exists
  require('lspconfig').clangd.setup {}
  require('conform').formatters_by_ft.cpp = { 'clang-format' }
end
