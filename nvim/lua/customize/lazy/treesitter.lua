return {
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter.configs').setup {
        ensure_installed = { 'c', 'cpp', 'python', 'lua', 'query', 'nix' },
        sync_install = false,
        auto_install = true,

        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },

        -- Enabling additional symbol-based navigation
        textobjects = {
          move = {
            enable = true,
            goto_next_start = {
              [']C'] = { query = '@code_cell.inner', desc = '[(])N]Next [c]ode block' },
              [']F'] = { query = '@function.outer', desc = '[(])N]ext [F]unction' },
            },
            goto_previous_start = {
              ['[C'] = { query = '@code_cell.inner', desc = '[([)P]revious [c]ode block' },
              ['[F'] = { query = '@function.outer', desc = '[([)P]revious [F]unction' },
            },
          },
        },
      }
    end,
  },
}
