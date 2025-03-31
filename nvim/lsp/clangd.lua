-- Adding an explicit prefix to where the pylsp server should be activated
local cmd_prefix = ''
if vim.fn.executable('_cmssw_src_path') and vim.fn.system("_cmssw_src_path") then
  cmd_prefix = vim.env.HOME .. "/.config/dot-bin/remote/cmssw/cmssw-"
end

return {
  cmd = { cmd_prefix .. 'clangd' },
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
