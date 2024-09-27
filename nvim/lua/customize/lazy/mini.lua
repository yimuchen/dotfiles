return {
  'echasnovski/mini.nvim',
  dependencies = { 'nvim-treesitter/nvim-treesitter-textobjects' }, -- For scope awareness
  config = function()
    -- Better Around/Inside textobjects
    --
    -- Examples:
    --  - va)  - [V]isually select [A]round [)]paren
    --  - yinq - [Y]ank [I]nside [N]ext [']quote
    --  - ci'  - [C]hange [I]nside [']quote
    local spec_treesitter = require('mini.ai').gen_spec.treesitter
    require('mini.ai').setup {
      n_lines = 1000, -- Required for large code blocks
      custom_textobjects = {
        -- Typical code objects
        ['F'] = spec_treesitter { a = '@function.outer', i = '@function.inner' },
        ['C'] = spec_treesitter { a = '@class.outer', i = '@class.inner' },
        -- Additional items for REPL interaction
        ['X'] = spec_treesitter { a = '@code_cell.outer', i = '@code_cell.inner' },
      },
    }

    -- Add/delete/replace surroundings (brackets, quotes, etc.)
    -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
    -- - sd'   - [S]urround [D]elete [']quotes
    -- - sr)'  - [S]urround [R]eplace [)] [']
    require('mini.surround').setup()

    -- Custom startup screen
    -- As this requires custom function, this will be setup in the plugins directory
    -- require('mini.starter').setup({})
  end,
}
