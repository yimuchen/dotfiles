return {
  "ibhagwan/fzf-lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {},
  config = function()
    local fzf = require("fzf-lua")
    -- Setting up the default theme
    fzf.setup({ "telescope" })

    -- Setting up key bindings with which-key
    local wk = require("which-key")
    wk.add({
      { '<leader>s', group = 'search', mode = 'n', icon = '' },
      { '<leader>sf', fzf.files, desc = '[S]earch [F]ile', icon = '' },
      { '<leader>st', fzf.git_files, desc = '[S]earch git-[T]racked', icon = '' },
      { '<leader>sh', fzf.help_tags, desc = '[S]earch [H]elp', icon = '' },
      { '<leader>sw', fzf.grep_cword, desc = '[S]earch current [W]ord' },
      { '<leader>sg', fzf.live_grep, desc = '[S]earch current [W]ord' },
      { '<leader>sk', fzf.keymaps, desc = '[S]earch [K]eymaps', icon = '' },
    })
  end
}
