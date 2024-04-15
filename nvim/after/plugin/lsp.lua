local lsp = require 'lsp-zero'
local tbuiltin = require 'telescope.builtin'

-- LSP related mappings definitions
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
  callback = function(event)
    local map = function(keys, func, desc)
      vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
    end

    local imap = function(keys, func, desc)
      vim.keymap.set('i', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
    end

    -- Navigation based on vim diagnostics
    map('[d', vim.diagnostic.goto_next, 'Go to previous [d]iagnostic')
    map(']d', vim.diagnostic.goto_prev, 'Go to next [d]iagnostic')
    map('<leader>e', vim.diagnostic.open_float, 'Show diagnostic [E]rror messages')
    map('<leader>q', vim.diagnostic.setloclist, 'Open diagnostic [Q]uickfix list')
    map('K', vim.lsp.buf.hover, 'Hover Documentation')
    map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

    -- Navigation based on lsp related functions. For multiple items, we will be
    -- using telescope
    map('gd', tbuiltin.lsp_definitions, '[G]o to [d]efinition')
    map('gr', tbuiltin.lsp_references, '[G]oto [R]eferences')
    map('gI', tbuiltin.lsp_implementations, '[G]oto [I]mplementation')
    map('<leader>ds', tbuiltin.lsp_document_symbols, '[D]ocument [S]ymbols')
    map('<leader>ws', tbuiltin.lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

    -- Keymaps for formatting using LSP
    map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
    imap('<C-h>', vim.lsp.buf.signature_help, 'Signature [H]elp')

    -- The following two autocommands are used to highlight references of the
    -- word under your cursor when your cursor rests there for a little while.
    --    See `:help CursorHold` for information about when this is executed
    --
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

-- Individual language server set ups
--
-- For more complicated setup splitting the installation and configurations to
-- the a separate lspconfig-<language>.lau file for simpler management
require('mason').setup {}
require('mason-lspconfig').setup {
  ensure_installed = { -- List of LSP to use by default
    'clangd', -- C++
    -- 'texlab', -- TeX/LaTeX
    -- Any additional server you might want added
    'rust_analyzer',
  },
  -- No additional handlers are required for now
  handlers = { lsp.default_setup },
}

-- Addtional tools that you might want installed
require('mason-tool-installer').setup {
  ensure_installed = {
    'clang-format', -- C/C++ formatting
    'latexindent', -- Latex formatting
    'codespell', -- Spell checking in variable name and comments
  },
  auto_update = false,
  run_on_start = false,
  debounce_hours = 5, -- at least 5 hours between attempts to install/update
}

-- Defualt formatting options
local conform = require 'conform'
conform.setup {
  formatters_by_ft = {
    ['_'] = { 'trim_whitespace' },
  },
}

-- Setting up keybindings for formatting
vim.keymap.set('n', '<leader>fb', function()
  conform.format { async = true, lsp_fallback = true }
end, { desc = '[F]ormat [b]uffer' })

vim.keymap.set('n', '<leader>fw', function() -- In case there is trailing white spaces in multiline strings
  conform.format { formatters = { 'trim_whitespace' } }
end, { desc = '[F]ormat [W]hitespaces' })

-- Additional wrapping, as formatter should not (by default) try to modify wrapping
-- since this can potentially break the meaning of strings
vim.keymap.set('n', '<leader>fp', 'gwap', { desc = '[F]ormat [P]aragraph (wrapping)' })

-- Because of how mini.ai works. we need to trigger the keystrokes in normal
-- mode ('n'), but the commands technically work in visual mode ('x'). See the
-- mini.lua file to see the definition of custom scopes
local gw_mini = function(scope)
  return function()
    vim.api.nvim_feedkeys('gw' .. scope, 'x', false)
  end
end
vim.keymap.set('n', '<leader>fm', gw_mini 'iM', { desc = '[F]ormat [M]ultiline string (wrap)' })
vim.keymap.set('n', '<leader>fc', gw_mini 'aC', { desc = '[F]ormat [C]omment' })
