-- JS filetypes are too fragmented to justify using a ftplugins stuff...
vim.lsp.config["svelte"] = {
  cmd = { 'svelteserver', '--stdio' },
  filetypes = { 'svelte' },
  root_markers = { 'package.json', '.git' },
}
vim.lsp.enable("svelte")

vim.lsp.config['cssls'] = {
  cmd = { 'vscode-css-language-server', '--stdio' },
  filetypes = { 'css', 'scss', 'less' },
  root_markers = { 'package.json', '.git' },
  settings = {
    css = { validate = true },
    scss = { validate = true },
    less = { validate = true },
  }
}
vim.lsp.enable("cssls")

vim.lsp.enable("ts_ls")

-- Format settings: using the prettier that is installed in the node
-- environment instead of requiring a global prettier to exist
local conform = require 'conform'
conform.formatters.npx_prettier = {
  command = 'npx',
  args = { 'prettier', '--stdin-filepath', '$FILENAME' },
}
conform.formatters_by_ft.html = { 'npx_prettier' }
conform.formatters_by_ft.css = { 'npx_prettier' }
conform.formatters_by_ft.javascript = { 'npx_prettier' }
conform.formatters_by_ft.svelte = { 'npx_prettier' }

-- Setting a separate parser for JSON using JQ (which is always available for nix-based installs)
conform.formatters_by_ft.json = { 'jq' }
