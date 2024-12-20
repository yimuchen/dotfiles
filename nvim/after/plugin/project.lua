-- Loading project specific configurations. The configurations here is mainly
-- for how neovim interacts with project-specific binaries, mainly the LSP
-- server and the code formatter. These binaries should always follow the
-- project environment as closely as possible so that ensure that the LSP can
-- sees the same environment as what will be used for execution, and the
-- formatter strictly follows the code style defined by the project.
--
-- There will be 2 primary ways that this is done, first neovim will check if a
-- project specific neovim configuration `.nvim/init.lua` file exists for
-- setting up the LSP configurations. If so it will source that file and no
-- further actions will be executed. If this file does not exists, then we will
-- automatically check for the following conditions from the current working
-- directory:
--
-- 1. CMSSW environments 2. The existence of apptainer executable script.
--
-- The existence of such item are stored as neovim global variables with the
-- naming vim.g._project_<XXX>. These are then passed over to the default LSP
-- configurations defined in the `.config/nvim/project-lsp` configuration.
-- These files should automatically handle the "standard" project
-- configurations to modify the LSP/formatter starting paths.

-- Detecting the CMSSW path if it exists
vim.g._project_cmssw_path = nil
if vim.fn.executable '_cmsexec' ~= 0 then
  local _cmssw_path = {}
  local _id = vim.fn.jobstart({ '_cmssw_src_path' }, {
    on_stderr = function(_, _, _) end,
    on_stdout = function(_, data, _)
      if data == nil or #data == 0 then
        return
      end
      vim.list_extend(_cmssw_path, data)
    end,
    on_exit = function(_, _, _) end,
  })
  vim.fn.jobwait { _id }
  vim.g._project_cmssw_path = _cmssw_path[1]
end

-- Detecting if a global ".apptainer_exec.sh" script exists
vim.g._project_apptainer_exec = nil
local executable_name = '.apptainer_exec.sh'
local container_rootdir = vim.fs.root(0, executable_name)
if container_rootdir ~= nil then
  vim.g._project_apptainer_exec = vim.fs.joinpath(container_rootdir, executable_name)
end

-- Adding additional functions that can be useful for loading the environment
vim.g._project_default_config_dir = vim.env.HOME .. '/.config/nvim/project-config/'
vim.g._project_load_default_lspconfig = function(filetype)
  vim.cmd('source ' .. vim.fs.joinpath(vim.g._project_default_config_dir, filetype .. '.lua'))
end

-- Simple method for adding prefix/post fix to the command required to the existing defaults
-- of the configurations found in lspconfig package
vim.g._lsp_setup = function(lsp_name, opt_override)
  -- Getting the original default settings
  local lsp_config = require('lspconfig.configs.' .. lsp_name).default_config

  -- Getting the new command from the option overrides
  lsp_config.cmd[1] = vim.fs.basename(lsp_config.cmd[1]) -- Stripping to just the executable name
  if opt_override.cmd ~= nil then
    lsp_config.cmd = opt_override.cmd
    opt_override.cmd = nil
  elseif opt_override.cmd_prefix ~= nil or opt_override.cmd_postfix ~= nil then
    local new_cmd = {}
    if opt_override.cmd_prefix ~= nil then
      vim.list_extend(new_cmd, opt_override.cmd_prefix)
      opt_override.cmd_prefix = nil
    end
    vim.list_extend(new_cmd, lsp_config.cmd)
    if opt_override.cmd_postfix ~= nil then
      vim.list_extend(new_cmd, opt_override.cmd_postfix)
      opt_override.cmd_postfix = nil
    end
    lsp_config.cmd = new_cmd
  end

  -- Getting any additional settings
  lsp_config = vim.tbl_extend('force', lsp_config, opt_override)
  require('lspconfig')[lsp_name].setup(lsp_config)
end

-- Simple method for adding prefix/post fix to the command required to the existing defaults
-- of the configurations found in conform
vim.g._conform_setup = function(fmt_name, opt_override)
  -- Getting the original default settings
  local fmt_config = require('conform.formatters.' .. fmt_name)

  -- Getting the new command from the option overrides
  fmt_config.command = vim.fs.basename(fmt_config.command) -- Stripping to just the executable name
  if opt_override.command ~= nil then
    fmt_config.command = opt_override.command
    opt_override.command = nil
  elseif opt_override.args ~= nil then
    fmt_config.args = opt_override.args
    opt_override.args = nil
  elseif opt_override.cmd_prefix ~= nil or opt_override.cmd_postfix ~= nil then
    local new_cmd = {}
    if opt_override.cmd_prefix ~= nil then
      vim.list_extend(new_cmd, opt_override.cmd_prefix)
      opt_override.cmd_prefix = nil
    end
    vim.list_extend(new_cmd, { fmt_config.command })
    if opt_override.cmd_postfix ~= nil then
      vim.list_extend(new_cmd, opt_override.cmd_postfix)
      opt_override.cmd_postfix = nil
    end
    fmt_config.command = new_cmd[1]
    fmt_config.args = vim.list_slice(new_cmd, 2)
  end

  -- Setting the filetype to run over
  local filetype = {}
  if opt_override.filetype ~= nil then
    filetype = opt_override.filetype
  end

  -- Getting any additional settings
  fmt_config = vim.tbl_extend('force', fmt_config, opt_override)

  require('conform.formatters')[fmt_name] = fmt_config
  for _, v in pairs(filetype) do
    require('conform').formatters_by_ft[v] = { fmt_name }
  end
end

-- Check if a local neovim configuration exists if it exists load that
-- If not, load all the default configurations in the library
local project_config = vim.fs.root(0, '.nvim/init.lua')
if project_config ~= nil then
  project_config = vim.fs.joinpath(project_config, '.nvim/init.lua')
  vim.cmd('source ' .. project_config)
else
  local defaults = vim.fn.glob(vim.fs.joinpath(vim.g._project_default_config_dir, '/*.lua'))
  defaults = vim.split(defaults, '\n', { trimempty = true })
  for _, lsp_config_file in pairs(defaults) do
    vim.cmd('source ' .. lsp_config_file)
  end
end
