return {
  --
  -- A bunch of nice eye candy!
  --
  { -- Monokai color scheme
    'loctvl842/monokai-pro.nvim',
    config = function()
      require('monokai-pro').setup {
        transparent_background = true,
        terminal_colors = true,
        devicons = true, -- highlight the icons of `nvim-web-devicons`
        styles = {
          comment = { italic = true },
          keyword = { italic = true },       -- any other keyword
          type = { italic = true },          -- (preferred) int, long, char, etc
          storageclass = { italic = true },  -- static, register, volatile, etc
          structure = { italic = true },     -- struct, union, enum, etc
          parameter = { italic = true },     -- parameter pass in function
          annotation = { italic = true },
          tag_attribute = { italic = true }, -- attribute of tag in reactjs
        },
        filter = 'pro',                      -- classic | octagon | pro | machine | ristretto | spectrum
        day_night = { enable = false },
        inc_search = 'background',           -- underline | background
        background_clear = {
          'toggleterm',
          'telescope',
          'which-key',
          'renamer',
          'notify',
        },
        plugins = {
          indent_blankline = {
            context_highlight = 'default',
            context_start_underline = true,
          },
        },
        override = function(_) end,
      }

      vim.cmd [[colorscheme monokai-pro]]
    end,
  },
  { -- indent guides for scope this
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    opts = {},
    config = function()
      local highlight = {
        'indent_guide_nonhl',
      }
      local hooks = require 'ibl.hooks'
      -- create the highlight groups in the highlight setup hook, so they are
      -- reset every time the color scheme changes
      hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
        vim.api.nvim_set_hl(0, 'indent_guide_nonhl', { fg = '#333333' })
      end)
      require('ibl').setup {
        enabled = true,
        scope = { enabled = true },
        indent = { highlight = highlight },
      }
    end,
  },
  { -- Comment highlighter for notes and to-dos
    'folke/todo-comments.nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = { signs = false },
  },
  { -- Lower status line of file
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('lualine').setup {
        options = {
          theme = 'monokai-pro',
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
    end,
  },
  {
    -- Upper line of breadcrumb for feature signature
    'Bekaboo/dropbar.nvim',
    -- optional, but required for fuzzy finder support
    dependencies = {
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make',
    },
    config = function()
      -- local dropbar_api = require 'dropbar.api'
      -- vim.keymap.set('n', '<Leader>;', dropbar_api.pick, { desc = 'Pick symbols in winbar' })
      -- vim.keymap.set('n', '[;', dropbar_api.goto_context_start, { desc = 'Go to start of current context' })
      -- vim.keymap.set('n', '];', dropbar_api.select_next_context, { desc = 'Select next context' })
    end,
  },
  { -- Moving command line to center, messages to top right
    'folke/noice.nvim',
    event = 'VeryLazy',
    opts = {},
    dependencies = {
      'MunifTanjim/nui.nvim',
      'rcarriga/nvim-notify',
    },
    config = function()
      require('notify').setup { background_colour = '#000000', stages = 'static' }
      require('noice').setup {
        views = {
          hover = { border = { style = "rounded", } }
        },
        lsp = {
          documentation = {
            view = "hover",
            opts = {
              position = { row = 1, col = 10 },
              size = {
                max_height = math.floor(0.8 * vim.api.nvim_win_get_height(0)),
                max_width = math.floor(0.7 * vim.api.nvim_win_get_width(0)),
              },
              background_color = '#FFF',
              border = { style = "rounded", color = "#555" }
            }
          },
        }
      }
    end,
  },
}
