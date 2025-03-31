-- Common setups to alwasy run
vim.lsp.enable('harper_ls')

-- Check if a local neovim configuration exists if it exists load that
-- If not, load all the default configurations in the library
local project_config = vim.fs.root(0, '.nvim/init.lua')
if project_config ~= nil then
  project_config = vim.fs.joinpath(project_config, 'init.lua')
  vim.cmd('source ' .. project_config)
else
  local defaults = vim.fn.glob(vim.fs.joinpath(vim.env.HOME .. '/.config/nvim/project-config', '/*.lua'))
  defaults = vim.split(defaults, '\n', { trimempty = true })
  for _, lsp_config_file in pairs(defaults) do
    vim.cmd('source ' .. lsp_config_file)
  end
end
