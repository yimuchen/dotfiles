-- Additional file type association for files that are don't follow the standard extension conventions
vim.filetype.add {
  extension = {
    service = 'cfg',
  },
  filename = {
    ['zshrc'] = 'sh',
    ['sshconfig'] = 'sshconfig',
    ['condarc'] = 'yaml',
    --["/etc/foo/config"] = "toml",
  },
}
