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
  if _cmssw_path[1] ~= '' then
    vim.g._project_cmssw_path = _cmssw_path[1]
  end
end

-- Detecting if a global ".apptainer_exec.sh" script exists
vim.g._project_apptainer_exec = nil
local executable_name = '.apptainer_exec.sh'
local container_rootdir = vim.fs.root(0, executable_name)
if container_rootdir ~= nil then
  vim.g._project_apptainer_exec = vim.fs.joinpath(container_rootdir, executable_name)
end

-- Detecting if there is a flake.nix the define the development shells
vim.g._project_nix_flake = vim.fs.root(0, 'flake.nix')

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
  local base_cmd = lsp_config.cmd -- Stripping the executable path to just the name
  base_cmd[1] = vim.fs.basename(lsp_config.cmd[1])

  local lsp_opt = vim.deepcopy(opt_override)
  if lsp_opt.cmd ~= nil then
    lsp_opt.cmd = lsp_opt.cmd -- Use the explicit command if defined
  elseif lsp_opt.cmd_prefix ~= nil or lsp_opt.cmd_postfix ~= nil then
    local new_cmd = {}
    if lsp_opt.cmd_prefix ~= nil then
      vim.list_extend(new_cmd, lsp_opt.cmd_prefix)
      lsp_opt.cmd_prefix = nil
    end
    vim.list_extend(new_cmd, base_cmd)
    if lsp_opt.cmd_postfix ~= nil then
      vim.list_extend(new_cmd, lsp_opt.cmd_postfix)
      lsp_opt.cmd_postfix = nil
    end
    lsp_opt.cmd = new_cmd
  end

  -- Setting up with new options
  require('lspconfig')[lsp_name].setup(lsp_opt)
end

-- Simple method for adding prefix/post fix to the command required to the existing defaults
-- of the configurations found in conform
vim.g._conform_setup = function(fmt_name, opt_override)
  -- Getting the original default settings
  local conform = require 'conform'
  local default_formatters = require 'conform.formatters'
  local fmt_config = default_formatters[fmt_name]
  fmt_config.command = vim.fs.basename(fmt_config.command) -- Stripping to just the executable name

  -- Making a copy of the input options
  local fmt_opt = vim.deepcopy(opt_override)

  -- Getting the new command from the option overrides
  if fmt_opt.command ~= nil then
    fmt_config.command = fmt_opt.command
    fmt_opt.command = nil
  elseif fmt_opt.args ~= nil then
    fmt_config.args = fmt_opt.args
    fmt_opt.args = nil
  elseif fmt_opt.cmd_prefix ~= nil or fmt_opt.cmd_postfix ~= nil then
    local new_cmd = {}
    if fmt_opt.cmd_prefix ~= nil then
      vim.list_extend(new_cmd, fmt_opt.cmd_prefix)
      fmt_opt.cmd_prefix = nil
    end
    vim.list_extend(new_cmd, { fmt_config.command })
    vim.list_extend(new_cmd, fmt_config.args)
    if fmt_opt.cmd_postfix ~= nil then
      vim.list_extend(new_cmd, fmt_opt.cmd_postfix)
      fmt_opt.cmd_postfix = nil
    end
    fmt_config.command = new_cmd[1]
    fmt_config.args = vim.list_slice(new_cmd, 2)
  end

  -- Getting any additional settings
  fmt_config = vim.tbl_extend('force', fmt_config, fmt_opt)
  local new_fmt = '_mod_' .. fmt_name
  conform.formatters[new_fmt] = fmt_config -- Must be inserted like this
  return new_fmt
end

-- Common methods for project setup. These option settings will be exposed as
-- global tables of neovim
vim.g._project_lsp_opt_default = nil
vim.g._project_fmt_opt_default = nil
if vim.g._project_cmssw_path ~= nil then
  vim.g._project_lsp_opt_default = { cmd_prefix = { '_cmsexec' } }
  vim.g._project_fmt_opt_default = { cmd_prefix = { '_cmsexec' } }
elseif vim.g._project_apptainer_exec ~= nil then
  vim.g._project_lsp_opt_default = {
    cmd_prefix = { vim.g._project_apptainer_exec },
    root_dir = function(_)
      return vim.fs.dirname(vim.g._project_apptainer_exec)
    end,
  }
  vim.g._project_fmt_opt_default = {
    cmd_prefix = { vim.g._project_apptainer_exec },
    cwd = function(_)
      return vim.fs.dirname(vim.g._project_apptainer_exec)
    end,
  }
elseif vim.g._project_nix_flake ~= nil and vim.env.SHLVL == "1" then
  -- If SHLVL is not 1, we assume that an embedded shell has already been set,
  -- and we will not attempt to start another modify the startup command (nix
  -- dev shells are slow)
  vim.g._project_lsp_opt_default = {
    cmd_prefix = {
      'nix',
      'develop',
      vim.g._project_nix_flake .. '#default',
      '--quiet',
      '--offline',
      '--command',
    },
  }
  vim.g._project_fmt_opt_default = {
    cmd_prefix = {
      'nix',
      'develop',
      vim.g._project_nix_flake .. '#default',
      '--quiet',
      '--offline',
      '--command',
    },
  }
end

-- Check if a local neovim configuration exists if it exists load that
-- If not, load all the default configurations in the library
local project_config = vim.fs.root(0, '.nvim/init.lua')
if project_config ~= nil then
  project_config = vim.fs.joinpath(project_config, 'init.lua')
  vim.cmd('source ' .. project_config)
else
  local defaults = vim.fn.glob(vim.fs.joinpath(vim.g._project_default_config_dir, '/*.lua'))
  defaults = vim.split(defaults, '\n', { trimempty = true })
  for _, lsp_config_file in pairs(defaults) do
    vim.cmd('source ' .. lsp_config_file)
  end
end
