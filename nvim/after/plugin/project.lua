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

local _get_cmssw_src_path = function()
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

local load_cmssw_config = function()
  -- Comment methods for loading in the configurations required for
  if vim.fn.executable '_cmsexec' == 0 then
    return false
  end
  local cmssw_path = _get_cmssw_src_path()
  if cmssw_path == '' or cmssw_path == nil then
    return false
  end
  vim.cmd('source ' .. vim.env.HOME .. '/.config/nvim/project-config/cmssw.lua')
  return true
end

-- Setting up the loading of the next time
vim.api.nvim_create_autocmd('VimEnter', {
  pattern = { '*' },
  callback = function()
    -- Checking for .nvim/init.lua configurations in the project and use that
    -- if it exists. Exit immediately instead of loading the next item
    if load_project_config() then
      return
    end

    if load_cmssw_config() then
      return
    end
  end,
})
