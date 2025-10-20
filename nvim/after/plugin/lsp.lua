-- Common LSP to load for multiple languages
vim.lsp.enable("harper_ls")

-- Additional settings that will be enabled if LSP is available
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
  callback = function(event)
    local fzf = require("fzf-lua")
    local wk = require 'which-key'

    -- Functions for diagnostic jumping
    local diag_jump = function(dir)
      return function()
        vim.diagnostic.jump { count = dir, float = true }
      end
    end

    -- Navigation based on LSP related functions. For multiple items, we will be
    -- using fuzzing finding plugin
    wk.add {
      -- Additional navigation key bindings
      { '[d',          diag_jump(1),                       desc = 'Go to previous [d]iagnostic' },
      { ']d',          diag_jump(-1),                      desc = 'Go to next [d]iagnostic' },
      { 'gd',          fzf.lsp_definitions,                desc = '[G]oto definition' },
      { 'gb',          ':e#<CR>',                          desc = '[G]o [b]ack to previous' },
      { 'gr',          fzf.lsp_references,                 desc = '[G]oto [R]eferences' },
      { 'gI',          fzf.lsp_implementations,            desc = '[G]oto [I]mplementation' },
      -- Additional search items
      { '<leader>ssd', fzf.lsp_document_symbols,           desc = '[S]search [S]ymbols in [D]ocument' },
      { '<leader>ssw', fzf.lsp_dynamic_workspace_symbolss, desc = '[S]earch [S]ymbols in [W]orkspace' },
      { '<leader>sd',  fzf.diagnostics_document,           desc = '[S]earch [D]iagnostics' },
      -- Opening preview buffers - Use ctrl key as modifier
      { '<C-h>',       vim.lsp.buf.hover,                  desc = '[H]over Documentation',            mode = 'ni' },
      { '<C-e>',       vim.diagnostic.open_float,          desc = 'Show diagnostic [E]rror messages', mode = 'ni' },
      -- For select interactions
      { '<leader>l',   group = '[L]SP' },
      { '<leader>la',  fzf.lsp_code_actions,               desc = "[L]SP [A]ction" },
      { '<leader>lr',  vim.lsp.buf.rename,                 desc = "[L]SP [R]ename" }
    }

    -- The following two auto commands are used to highlight references
    -- of the word under your cursor when your cursor rests there for a
    -- little while. When you move your cursor, the highlights will be
    -- cleared.
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
