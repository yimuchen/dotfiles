-- Setting up the loading of the next time
vim.api.nvim_create_autocmd('VimEnter', {
  pattern = { '*' },
  callback = function()
    local config_name = 'init.lua'
    local project_config = vim.fs.root(0, vim.fs.joinpath('.nvim', config_name))
    if project_config ~= nil then
      project_config = vim.fs.joinpath(project_config, config_name)
      vim.cmd('source ' .. project_config)
      -- vim.cmd('source ' .. project_config)
    end
  end,
})
