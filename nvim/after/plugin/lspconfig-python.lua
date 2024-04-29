-- Mason will not be used for the various installation, as black, flake8 and
-- isort is are plugins not registered under mason.
require('lspconfig').pylsp.setup {
  settings = {
    pylsp = {
      plugins = {
        -- Use flake8 instead of pycodestyle
        flake8 = { enabled = true },
        pycodestyle = { enabled = false },
        -- Default formatting
        black = { enabled = true },
        isort = { enable = true },
      },
    },
  },
}

-- Formatting methods
require('conform').formatters_by_ft.python = { 'isort', 'black' }

-- Additional surrounding function
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'python',
  callback = function()
    require('mini.ai').config.custom_textobjects['M'] = function()
      --- Triple quote /excluding new lines
      return { string.format('%s().-()%s', '"""\n', '\n *"""\n') }
    end
  end,
})

--
-- Additional settings for notebook and REPL setup setups
--
require('otter').setup {}
require('jupytext').setup { -- Casting notebooks as markdown files
  style = 'markdown',
  output_extension = 'md',
  force_ft = 'markdown',
}
require('quarto').setup {
  codeRunner = {
    enable = true,
    ft_runners = {
      python = 'molten',
    },
  },
}

-- Common settings for all REPL related functions
vim.keymap.set('n', '<leader>mi', ':MoltenInit<CR>', { silent = true, desc = '[M]olten [I]nitialize' })
vim.keymap.set('n', '<leader>mel', ':MoltenEvaluateLine<CR>', { silent = true, desc = '[M]olten [E]valuate [L]ine' })
vim.keymap.set('v', '<leader>mev', ':<C-u>MoltenEvaluateVisual<CR>gv', { silent = true, desc = '[M]olten [E]valuate [V]isual' })
vim.keymap.set('n', '<leader>moh', ':MoltenHideOutput<CR>', { silent = true, desc = '[M]olten [O]utput [H]ide' })
vim.keymap.set('n', '<leader>moe', ':noautocmd MoltenEnterOutput<CR>', { silent = true, desc = '[M]olten [O]utput [E]nter' })

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'markdown', -- Only working on markdown file that is converted from notebook files
  callback = function()
    -- vim.notify 'This is a message'
    local buffer_name = vim.api.nvim_buf_get_name(0)
    vim.print('Checking file name' .. string.sub(buffer_name, -6) .. '[.ipynb]')
    if string.sub(buffer_name, -6) ~= '.ipynb' then
      return -- Early exit if it is not a notebook file
    end
    vim.print 'Activating plugin quarto'
    -- Quarto/Molten process interfaces to run cells
    require('quarto').activate()
    local runner = require 'quarto.runner'
    vim.keymap.set('n', '<leader>mrc', runner.run_cell, { desc = '[M]olten [R]un [C]ell', silent = true })
    vim.keymap.set('n', '<leader>mra', runner.run_above, { desc = '[M]olten [R]un [a]bove', silent = true })
    vim.keymap.set('n', '<leader>mrA', runner.run_all, { desc = '[M]olten [R]un [A]ll', silent = true })
    vim.keymap.set('n', '<leader>mrl', runner.run_line, { desc = '[M]olten [R]un [l]ine', silent = true })
    vim.keymap.set('v', '<leader>mr', runner.run_range, { desc = '[M]olten [R]un visual', silent = true })

    -- Embedded language displays
    -- languages / completion / diagnostics / treesitter query
    vim.print 'Activating plugin otter'
    require('otter').activate({ 'python' }, true, true, nil)
  end,
})

--
-- Snippets
--
local ls = require 'luasnip'
--local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
--local f = ls.function_node
--local c = ls.choice_node
--local d = ls.dynamic_node
--local r = ls.restore_node

ls.add_snippets('python', {
  -- trigger is `fn`, second argument to snippet-constructor are the nodes to
  -- insert into the buffer on expansion.
  ls.snippet('__main__', {
    t { 'if __name__ == "__main__":', '    ' },
    i(0),
  }),
})
