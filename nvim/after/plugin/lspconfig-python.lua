-- Mason will not be used for the various installation, as black, flake8 and
-- isort is are plugins not registered under mason.

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
