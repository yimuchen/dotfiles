-- Setting the LSP, linters and formatters for CPP and python files to point to the
-- executable in the container/internal CMSSW environment instead
local cmssw_path = vim.g._get_cmssw_src_path()
local lspconfig = require 'lspconfig'
local conform = require 'conform'

-- Clangd configurations
lspconfig['clangd'].setup {
  cmd = { '_cmsexec', 'clangd', '--compile-commands-dir=' .. cmssw_path .. '/../' },
  root_dir = function(_)
    return cmssw_path
  end,
  -- single_file_support = false,
}
local clang_format_cmd = { 'clang-format' }
vim.list_extend(clang_format_cmd, require('conform.formatters').clang_format.args)
vim.list_extend(clang_format_cmd, { '--style=file' })
conform.formatters.cmssw_clang_format = {
  command = '_cmsexec',
  args = clang_format_cmd,
  stdin = true,
}
conform.formatters_by_ft.cpp = { 'cmssw_clang_format' }

-- Python LSP configurations
lspconfig['pylsp'].setup {
  cmd = { '_cmsexec', 'pylsp' },
}

lspconfig['ruff'].setup {
  cmd = { '_cmsexec', 'ruff', 'server', '--preview' },
}

-- Do *not* setup formatting for python code now. As CMSSW code is usually done
-- in collaboration with others That may *not* have formatting properly setup.

-- Additional LSP configurations to load in directly from default. These have global
-- LSP executable binaries that are saved by the user nix instance
vim.g._load_default_lspconfig 'md'
vim.g._load_default_lspconfig 'sh'
vim.g._load_default_lspconfig 'tex' -- For grammar checking in md files
