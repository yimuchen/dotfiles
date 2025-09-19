return {
  cmd = { vim.g.get_prefixed_exec('ruff'), "server" },
  filetypes = { 'python' },
  root_markers = {
    'pyproject.toml',
    'setup.py',
    'setup.cfg',
    'requirements.txt',
    'Pipfile',
  },
}
