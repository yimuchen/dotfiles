-- Additional settings for specific language servers
require("lspconfig").pylsp.setup({
  settings = {
    pylsp = {
      plugins = {
        -- Use flake8 instead of pycodestyle
        flake8 = { enabled = true },
        pycodestyle = { enabled = false },
        -- Default formatting
        black = { enabled = true },
        isort = { enable = true },
      },
    },
  },
})

