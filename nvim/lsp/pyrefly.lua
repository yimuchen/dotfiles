return {
  cmd = { vim.g.get_prefixed_exec('pyrefly'), 'lsp' },
  filetypes = { 'python' },
  root_markers = {
    'pyproject.toml',
    'setup.py',
    'setup.cfg',
    'requirements.txt',
    'Pipfile',
  }
}
