local cmd_prefix = ''

-- Adding an explicit prefix to where the pylsp server should be activated
if vim.fn.executable('_cmssw_src_path') ~= 0 and vim.fn.system("_cmssw_src_path") ~= "" then
  cmd_prefix = vim.env.HOME .. "/.config/dot-bin/remote/cmssw/cmssw-"
elseif vim.env.CONDA_PREFIX ~= nil then
  cmd_prefix = vim.env.CONDA_PREFIX .. "/bin/"
elseif vim.fs.root(0, { ".apptainer-pylsp" }) ~= nil then
  cmd_prefix = vim.fs.root(0, { ".apptainer-pylsp" }) .. "/.apptainer-"
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
  settings = {}
}
