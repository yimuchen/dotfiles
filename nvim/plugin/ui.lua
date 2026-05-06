vim.pack.add({
  'https://github.com/gbprod/nord.nvim',
  'https://github.com/lukas-reineke/indent-blankline.nvim',
  'https://github.com/folke/todo-comments.nvim',
  'https://github.com/nvim-lualine/lualine.nvim',
  'https://github.com/Bekaboo/dropbar.nvim',
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/nvim-tree/nvim-web-devicons',
})
-- Using new neovim UI2 framework for handling messages
require("vim._core.ui2").enable({
  enabled = true,
  msg = { -- Send vim.api.nvim_echo items to a transient items at the corner
    targets = 'msg',
    msg = { height = 0.5, timeout = 5000 },
  },
})
-- Having items be a rounded item
vim.opt.winborder = "rounded"

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

-- LSP progress bar, taken from
-- https://www.reddit.com/r/neovim/comments/1rcvliq/ghostty_lsp_progress_bar/
vim.api.nvim_create_autocmd("LspProgress", {
  callback = function(ev)
    local value = ev.data.params.value or {}
    local msg = value.message or "done"
    -- rust analyszer in particular has really long LSP messages so truncate them
    if #msg > 40 then
      msg = msg:sub(1, 37) .. "..."
    end
    vim.api.nvim_echo({ { msg } }, false, {
      id = "lsp",
      kind = "progress",
      title = value.title,
      source = 'lsp-progress',
      status = value.kind ~= "end" and "running" or "success",
      percent = value.percentage,
    })
  end,
})

-- Setting up in indent guilds
local highlight = { 'indent_guide_nonhl' }
local hooks = require('ibl.hooks')
hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
  vim.api.nvim_set_hl(0, 'indent_guide_nonhl', { fg = '#666666' })
end)
require('ibl').setup {
  enabled = true,
  scope = { enabled = true },
  indent = { highlight = highlight },
}
