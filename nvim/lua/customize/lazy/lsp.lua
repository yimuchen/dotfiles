return {
  -- For LSP support in embedded documents. No additional settings will be placed here
  { 'nvim-treesitter/nvim-treesitter' },
  -- Auto-completion engine
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-nvim-lsp',
      'saadparwaiz1/cmp_luasnip',
      { -- Snippet engine for writing custom snippets
        'L3MON4D3/LuaSnip',
        version = 'v2.*',
        build = 'make install_jsregexp',
      },
      'jmbuhr/otter.nvim',
    },
    config = function()
      -- Autocomplete configuration
      local cmp = require 'cmp'
      local cmp_select = { behavior = cmp.SelectBehavior.Select }
      local luasnip = require 'luasnip'
      luasnip.config.setup {}
      cmp.setup {
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        sources = {
          { name = 'path' },
          { name = 'otter' }, -- Auto completion with otter!
          { name = 'nvim_lsp' },
          { name = 'nvim_lua' },
          { name = 'luasnip' },
          { name = 'minuet' },
        },
        mapping = cmp.mapping.preset.insert {
          ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
          ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
          ['<C-y>'] = cmp.mapping.confirm { select = true },
          ['<C-space>'] = cmp.mapping.complete {},
        },
        performance = {
          fetching_timeout = 2000,
        }
      }
    end,
  },

  -- For additional lua LSP when editing neovim configurations
  {
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = { library = { 'luvit-meta/library' }, },
    dependencies = { { 'Bilal2453/luvit-meta', lazy = true } },
  },

  -- Document outline
  {
    'hedyhli/outline.nvim',
    config = function()
      vim.keymap.set('n', '<leader>o', '<cmd>Outline<CR>', { desc = 'Toggle [O]utline' })
      require('outline').setup {}
    end,
  },

  -- Jupyter notebook editing
  {
    'GCBallesteros/jupytext.nvim',
    dependencies = { 'jmbuhr/otter.nvim' },
    config = function()
      require('jupytext').setup {
        custom_language_formatting = { -- Setting notebook files to look like Markdown
          python = {
            extension = 'md',
            style = 'markdown',
            force_ft = 'markdown',
          },
        },
      }
    end,
  },

}
