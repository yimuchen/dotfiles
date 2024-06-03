return { -- LSP configurations and language related plugins
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'stevearc/conform.nvim', -- Formatting engine
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
    },
    config = function()
      local tbuiltin = require 'telescope.builtin'

      -- LSP related mappings definitions
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local nmap = function(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          local imap = function(keys, func, desc)
            vim.keymap.set('i', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          -- Navigation based on vim diagnostics
          nmap('[d', vim.diagnostic.goto_next, 'Go to previous [d]iagnostic')
          nmap(']d', vim.diagnostic.goto_prev, 'Go to next [d]iagnostic')
          nmap('<leader>e', vim.diagnostic.open_float, 'Show diagnostic [E]rror messages')
          nmap('<leader>q', vim.diagnostic.setloclist, 'Open diagnostic [Q]uickfix list')
          nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
          nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

          -- Navigation based on lsp related functions. For multiple items, we will be
          -- using telescope
          nmap('gd', tbuiltin.lsp_definitions, '[G]o to [d]efinition')
          nmap('gb', ':e#<CR>', '[G]o [b]ack to previous')
          nmap('gr', tbuiltin.lsp_references, '[G]oto [R]eferences')
          nmap('gI', tbuiltin.lsp_implementations, '[G]oto [I]mplementation')
          nmap('<leader>ds', tbuiltin.lsp_document_symbols, '[D]ocument [S]ymbols')
          nmap('<leader>ws', tbuiltin.lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
          nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
          imap('<C-h>', vim.lsp.buf.signature_help, 'Signature [H]elp')

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

      -- Common formatting options
      local conform = require 'conform'
      conform.setup {
        formatters_by_ft = {
          ['_'] = { 'trim_whitespace' },
          -- ['*'] = { 'injected' }, -- Try to allow injected formatter for all items
        },
      }
      vim.api.nvim_create_autocmd('FileType', {
        pattern = { '*' },
        callback = function(opts)
          local ft = vim.bo[opts.buf].filetype
          -- Special file types to exclude from injected formats
          local exclude_inject = { svelte = true }
          if not exclude_inject[ft] then
            conform.formatters_by_ft['*'] = { 'injected' }
          end
        end,
      })

      -- Setting up keybindings for formatting
      vim.keymap.set('n', '<leader>fb', function()
        conform.format { async = true, lsp_fallback = false }
      end, { desc = '[F]ormat selected [b]uffer' })
      vim.keymap.set('n', '<leader>fw', function() -- In case there is trailing white spaces in multiline strings
        conform.format { formatters = { 'trim_whitespace' } }
      end, { desc = '[F]ormat [W]hitespaces' })

      vim.api.nvim_create_user_command('ConformFormat', function(opt) -- Running a custom formatter directly by name
        conform.format { formatters = { opt.fargs[1] } }
      end, {
        nargs = 1,
        complete = function(arglead, cmdline, cursorpos)
          local all_formatters = {}
          -- First loop is for modified conformers
          for name, _ in pairs(conform.formatters) do
            if string.sub(name, 0, #arglead) == arglead then
              all_formatters[name] = true
            end
          end
          for name, _ in pairs(require('conform.formatters').list_all_formatters()) do
            if string.sub(name, 0, #arglead) == arglead and all_formatters[name] == nil then
              all_formatters[name] = true
            end
          end

          local ret_list = {}
          for name, _ in pairs(all_formatters) do
            table.insert(ret_list, name)
          end
          return ret_list
        end,
      })

      -- Additional wrapping, as formatter should not (by default) try to
      -- modify wrapping since this can potentially break the meaning of
      -- strings
      vim.keymap.set('n', '<leader>fp', 'gwap', { desc = '[F]ormat [P]aragraph (wrapping)' })

      -- Because of how mini.ai works. we need to trigger the keystrokes in
      -- normal mode ('n'), but the commands technically work in visual mode
      -- ('x'). See the mini.lua file to see the definition of custom scopes
      local call_mini = function(cmd)
        return function()
          vim.api.nvim_feedkeys(cmd, 'x', false)
        end
      end
      vim.keymap.set('n', '<leader>fm', call_mini 'gwiM', { desc = '[F]ormat [M]ultiline string (wrap)' })
      vim.keymap.set('n', '<leader>fc', call_mini 'gwgc', { desc = '[F]ormat [C]omment' })
      vim.keymap.set('n', '<leader>/', call_mini 'gcc', { desc = 'Toggle comment' })
      vim.keymap.set('x', '<leader>/', call_mini 'gc', { desc = 'Toggle comment' })

      -- Main package to configure
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
}
