vim.pack.add({
  'https://github.com/gbprod/nord.nvim',
  'https://github.com/lukas-reineke/indent-blankline.nvim',
  'https://github.com/folke/todo-comments.nvim',
  'https://github.com/nvim-lualine/lualine.nvim',
  'https://github.com/Bekaboo/dropbar.nvim',
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/nvim-tree/nvim-web-devicons',
  'https://github.com/folke/noice.nvim',
  'https://github.com/MunifTanjim/nui.nvim',
  'https://github.com/rcarriga/nvim-notify',
})

-- Setting up the color scheme
require("nord").setup({ transparent = true })
vim.cmd.colorscheme("nord")

-- Setting up the bottom line
require('lualine').setup {
  options = {
    theme = 'nord',
    section_separators = { left = '', right = '' },
    component_separators = { left = '│', right = '│' }
  },
  sections = {
    lualine_a = { 'mode' },
    lualine_b = { 'branch', 'diff', 'diagnostics' },
    lualine_c = { { 'filename', path = 1 } },
    lualine_x = { 'encoding', 'fileformat', 'filetype' },
    lualine_y = { 'progress' },
    lualine_z = { 'location' },
  },
}

-- Setting up the UI via noice/notify
require('notify').setup({ background_colour = '#000000', stages = 'static' })
require('noice').setup({
  views = {
    hover = { border = { style = "rounded", } }
  },
  lsp = {
    documentation = {
      view = "vsplit",
      opts = {
        enter = false,
        position = "right",
        size = "40%"
      }
    },
  }
})

-- Setting up in indent guilds
local highlight = { 'indent_guide_nonhl' }
local hooks = require('ibl.hooks')
hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
  vim.api.nvim_set_hl(0, 'indent_guide_nonhl', { fg = '#333333' })
end)
require('ibl').setup {
  enabled = true,
  scope = { enabled = true },
  indent = { highlight = highlight },
}
