local cmd_prefix = ''

-- Adding an explicit prefix to where the pyrefly server should be activated
if vim.fn.executable('_cmssw_src_path') ~= 0 and vim.fn.system("_cmssw_src_path") ~= "" then
  cmd_prefix = vim.env.HOME .. "/.config/dot-bin/remote/cmssw/cmssw-"
elseif vim.env.CONDA_PREFIX ~= nil then
  cmd_prefix = vim.env.CONDA_PREFIX .. "/bin/"
elseif vim.fs.root(0, { ".apptainer-pyrefly" }) ~= nil then
  cmd_prefix = vim.fs.root(0, { ".apptainer-pyrefly" }) .. "/.apptainer-"
end

return {
  cmd = { cmd_prefix .. 'pyrefly', 'lsp' },
  filetypes = { 'python' },
  root_markers = {
    'pyproject.toml',
    'setup.py',
    'setup.cfg',
    'requirements.txt',
    'Pipfile',
  }
}
