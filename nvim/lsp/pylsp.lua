-- modexec = require("modexec")
local cmd_prefix = ''

-- Adding an explicit prefix to where the pylsp server should be activated
if vim.fn.executable('_cmssw_src_path') ~= 0 and vim.fn.system("_cmssw_src_path") ~= "" then
  vim.print(vim.fn.system('_cmssw_src_path'))
  cmd_prefix = vim.env.HOME .. "/.config/dot-bin/remote/cmssw/cmssw-"
elseif vim.env.CONDA_PREFIX ~= nil then
  cmd_prefix = vim.env.CONDA_PREFIX .. "/bin/"
end

return {
  cmd = { cmd_prefix .. 'pylsp' },
  filetypes = { 'python' },
  root_markers = {
    'pyproject.toml',
    'setup.py',
    'setup.cfg',
    'requirements.txt',
    'Pipfile',
  },
  settings = {
    plugins = {
      ruff = {
        enabled = true,
        formatEnabled = true,
        format = { 'I' },   -- Attempt to sort imports if possible
        lineLength = 88,    -- Default line, will be overwritten by anything in pyproject.toml or similar
      },
    },
  }
}
