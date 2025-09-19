return {
  cmd = { vim.g.get_prefixed_exec('pylsp') },
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
