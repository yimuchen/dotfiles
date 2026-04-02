-- Additional packages to help with nonstandard syntax navigation and operations
vim.pack.add({
  'https://github.com/nvim-treesitter/nvim-treesitter',
  'https://github.com/nvim-treesitter/nvim-treesitter-textobjects', -- For generating additional objects
  'https://github.com/hedyhli/outline.nvim',
  'https://github.com/GCBallesteros/jupytext.nvim',
  'https://github.com/jmbuhr/otter.nvim',     -- For multi-language files
  'https://github.com/stevearc/conform.nvim',
  'https://github.com/echasnovski/mini.nvim', -- For additional motions
})
local wk = require('which-key')

-- Outline of current document (handled by LSP/treesitter
require("outline").setup()
wk.add({ { '<leader>o', '<cmd>Outline<CR>', desc = 'Toggle [O]utline' } })

-- Adding additional scope methods via mini/ai package
local spec_treesitter = require('mini.ai').gen_spec.treesitter
require('mini.ai').setup {
  n_lines = 10000, -- Required for large code blocks
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

-- Tree -sitter shenanigans update
require('nvim-treesitter').setup {
  ensure_installed = { 'c', 'cpp', 'python', 'markdown', 'markdown-inline', 'lua', 'query', 'nix' },
  highlight = { enable = true, additional_vim_regex_highlighting = false },
  sync_install = false,
  auto_install = true,
  -- Enabling additional symbol-based navigation, using items defined by mini-ai
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
vim.api.nvim_create_autocmd('PackChanged', { -- Automatically run TSUpdate when package is updated
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if name == 'nvim-treesitter' and kind == 'update' then
      if not ev.data.active then vim.cmd.packadd('nvim-treesitter') end
      vim.cmd('TSUpdate')
    end
  end
})


-- Formatter set
local conform = require('conform')
conform.setup {
  formatters_by_ft = {
    ['_'] = { 'trim_whitespace' },
    -- ['*'] = { 'injected' }, -- Try to allow injected formatter for all items
  },
  async = true
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
  -- In most cases, the LSP should be configured to be the formatter
  -- (similar to calling vim.lsp.buf.format())
  conform.format { lsp_format = "first", timeout_ms = 10000 }
  -- Always try to trim whitespace
  conform.format { formatters = { 'trim_whitespace' } }
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
  { '<leader>f',  group = 'format' },
  { '<leader>fb', format_buffer,            desc = '[F]ormat [B]uffer' },
  { '<leader>fw', format_whitespace,        desc = '[F]ormat [W]hitespace' },
  { '<leader>fp', 'gwap',                   desc = '[F]ormat [P]aragraph' },
  { '<leader>fm', format_multiline_str,     desc = '[F]ormat [M]ultiline string' },
  { '<leader>fc', format_multiline_comment, desc = '[F]ormat, [C]omment' },
  -- Toggling code on/off I will technically classify as formatting
  { '<leader>/',  toggle_comment,           desc = 'Toggle comment',             mode = 'nx' },
}

-- Running a custom formatter directly by name
vim.api.nvim_create_user_command('ConformFormat',
  function(opt)
    conform.format { formatters = { opt.fargs[1] } }
  end,
  {
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
  }
)

-- For jupyter notebook editing
require('jupytext').setup {
  custom_language_formatting = { -- Setting notebook files to look like Markdown
    python = {
      extension = 'md',
      style = 'markdown',
      force_ft = 'markdown',
    },
  },
}
