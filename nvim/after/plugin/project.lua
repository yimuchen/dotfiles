local load_project_config = function()
  -- Method for loading an explicitly define project level configurations
  local config_name = 'init.lua'
  local project_config = vim.fs.root(0, vim.fs.joinpath('.nvim', config_name))
  if project_config ~= nil then
    project_config = vim.fs.joinpath(project_config, config_name)
    vim.cmd('source ' .. project_config)
    return true
  end
  return false
end

-- Global function for getting the `CMSSW_X_Y_Z/src` path using the existing
-- external command defined in CMSSW tools.
vim.g._get_cmssw_src_path = function()
  local cmssw_path = {}
  local id = vim.fn.jobstart({ '_cmssw_src_path' }, {
    on_stderr = function(_, _, _) end,
    on_stdout = function(_, data, _)
      if data == nil or #data == 0 then
        return
      end
      vim.list_extend(cmssw_path, data)
    end,
    on_exit = function(_, _, _) end,
  })
  vim.fn.jobwait { id }
  return cmssw_path[1]
end

-- Alias for project configurations directory. This should be standard in all
-- installations.
vim.g._project_config_dir = vim.env.HOME .. '/.config/nvim/project-config/'

local load_cmssw_config = function()
  -- Comment methods for loading in the configurations required for
  if vim.fn.executable '_cmsexec' == 0 then
    return false
  end
  local cmssw_path = vim.g._get_cmssw_src_path()
  if cmssw_path == '' or cmssw_path == nil then
    return false
  end
  vim.cmd('source ' .. vim.g._project_config_dir .. 'cmssw.lua')
  return true
end

vim.g._get_apptainer_script = function()
  local executable_name = '.apptainer_exec.sh'
  local container_rootdir = vim.fs.root(0, executable_name)
  if container_rootdir ~= nil then
    return vim.fs.joinpath(container_rootdir, executable_name)
  else
    return nil
  end
end

vim.g._load_default_lspconfig = function(filetype)
  vim.cmd('source ' .. vim.g._project_config_dir .. '/lsp_defaults/' .. filetype .. '.lua')
end

local load_apptainer = function()
  if vim.g._get_apptainer_script() ~= nil then
    vim.cmd('source ' .. vim.g._project_config_dir .. 'apptainer.lua')
    return true
  end
  return false
end

local load_defaults = function()
  vim.cmd('source ' .. vim.g._project_config_dir .. 'lsp_defaults.lua')
end

-- Checking for .nvim/init.lua configurations in the project and use that
-- if it exists. Exit immediately instead of loading the next item
if load_project_config() then
  return
elseif load_cmssw_config() then
  return
elseif load_apptainer() then
  return
else
  load_defaults()
end
