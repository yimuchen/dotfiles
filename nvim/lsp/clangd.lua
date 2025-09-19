return {
  cmd = { vim.g.get_prefixed_exec('clangd') },
  filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda', 'proto' },
  root_markers = {
    '.clangd',
    '.clang-tidy',
    '.clang-format',
    'compile_commands.json',
    'compile_flags.txt',
    'configure.ac'
  },
  -- capabilities = {
  --   textDocument = {
  --     completion = {
  --       editsNearCursor = true,
  --     },
  --   },
  --   offsetEncoding = { 'utf-8', 'utf-16' },
  -- },
}
