return { -- LSP configurations and language related plugins
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'hrsh7th/nvim-cmp', -- Autocompletion engine
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-nvim-lsp',
      'saadparwaiz1/cmp_luasnip',
      { -- Snippet engine for writing custom snippets
        'L3MON4D3/LuaSnip',
        version = 'v2.*',
        build = 'make install_jsregexp',
      },
      -- For LSP support in embedded documents
      'jmbuhr/otter.nvim',
      'nvim-treesitter/nvim-treesitter',
    },
    config = function()
      local ts_builtin = require 'telescope.builtin'
      local wk = require 'which-key'

      -- LSP related mappings definitions
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          -- Navigation based on lsp related functions. For multiple items, we will be
          -- using telescope
          wk.add {
            -- Additional navigation keybind
            { '[d', vim.diagnostic.goto_next, desc = 'Go to previous [d]iagnostic' },
            { ']d', vim.diagnostic.goto_prev, desc = 'Go to next [d]iagnostic' },
            { 'gd', ts_builtin.lsp_definitions, desc = '[G]oto definition' },
            { 'gb', ':e#<CR>', desc = '[G]o [b]ack to previous' },
            { 'gr', ts_builtin.lsp_references, desc = '[G]oto [R]eferences' },
            { 'gI', ts_builtin.lsp_implementations, desc = '[G]oto [I]mplementation' },
            -- Additional search items
            { '<leader>ssd', ts_builtin.lsp_document_symbols, desc = '[S]search [S]ymbols in [D]ocument' },
            { '<leader>ssw', ts_builtin.lsp_dynamic_workspace_symbols, desc = '[S]earch [S]ymbols in [W]orkspace' },
            { '<leader>sd', ts_builtin.diagnostics, desc = '[S]earch [D]iagnostics' },
            -- Opening preview buffers - Use CTRL as modifier!
            { '<C-h>', vim.lsp.buf.hover, desc = '[H]over Documentation', mode = 'ni' },
            { '<C-e>', vim.diagnostic.open_float, desc = 'Show diagnostic [E]rror messages', mode = 'ni' },
            -- Actions that will directly modify the text buffer
            { '<leader>a', group = 'Alter' },
            { '<leader>ar', vim.lsp.buf.rename, desc = '[A]ction [R]ename' },
            { '<leader>af', vim.lsp.buf.code_action, desc = '[A]ction LSP [F]ix' },
          }

          -- The following two autocommands are used to highlight references of the
          -- word under your cursor when your cursor rests there for a little while.
          -- When you move your cursor, the highlights will be cleared (the second autocommand).
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.server_capabilities.documentHighlightProvider then
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              callback = vim.lsp.buf.clear_references,
            })
          end
        end,
      })

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
        },
        mapping = cmp.mapping.preset.insert {
          ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
          ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
          ['<C-y>'] = cmp.mapping.confirm { select = true },
          ['<C-space>'] = cmp.mapping.complete {},
        },
      }
    end,
  },
  {
    'folke/lazydev.nvim', -- For additional LSP configurations when for neovim configuration
    ft = 'lua', -- only load on lua files
    opts = {
      library = {
        -- Library items can be absolute paths
        -- "~/projects/my-awesome-lib",
        -- When relative, you can also provide a path to the library in the plugin dir
        'luvit-meta/library', -- see below
      },
    },
    dependencies = {
      { 'Bilal2453/luvit-meta', lazy = true }, -- optional `vim.uv` typings
    },
  },
  {
    'hedyhli/outline.nvim',
    config = function()
      vim.keymap.set('n', '<leader>o', '<cmd>Outline<CR>', { desc = 'Toggle [O]utline' })
      require('outline').setup {}
    end,
  },
}
