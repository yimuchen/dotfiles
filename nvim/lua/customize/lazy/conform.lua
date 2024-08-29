return {
  {
    'stevearc/conform.nvim', -- Formatting engine
    config = function()
      local conform = require 'conform'
      local wk = require 'which-key'
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

      -- Setting up functions for formatting
      local format_buffer = function()
        conform.format { async = true, lsp_fallback = false }
      end
      local format_whitespace = function()
        conform.format { formatters = { 'trim_whitespace' } }
      end

      -- Because of how mini.ai works, we need to trigger the keystrokes in
      -- normal mode ('n'), but the commands technically work in visual mode
      -- ('x'). See the mini.lua file to see the definition of custom scopes
      local call_mini = function(cmd)
        return function()
          vim.api.nvim_feedkeys(cmd, 'x', false)
        end
      end
      local format_multiline_str = call_mini 'gwiM'
      local format_multiline_comment = call_mini 'gwgc'
      local toggle_comment = call_mini 'gcc'

      wk.add {
        { '<leader>f', group = 'format' },
        { '<leader>fb', format_buffer, desc = '[F]ormat [B]uffer' },
        { '<leader>fw', format_whitespace, desc = '[F]ormat [W]hitespace' },
        { '<leader>fp', 'gwap', desc = '[F]ormat [P]aragraph' },
        { '<leader>fm', format_multiline_str, desc = '[F]ormat [M]ultiline string' },
        { '<leader>fc', format_multiline_comment, desc = '[F]ormat, [C]omment' },
        -- Toggling code on/off I will technically classify as formatting
        { '<leader>/', toggle_comment, desc = 'Toggle comment', mode = 'nx' },
      }

      -- Running a custom formatter directly by name
      vim.api.nvim_create_user_command('ConformFormat', function(opt)
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
    end,
  },
}
