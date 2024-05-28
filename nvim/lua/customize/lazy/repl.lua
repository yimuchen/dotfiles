return {
  -- REPL/notebook interactions within vim
  {
    'benlubas/molten-nvim',
    version = '<2.0.0', -- Pinning this version for now
    dependencies = {
      '3rd/image.nvim', -- For image display
      'quarto-dev/quarto-nvim', -- Slicing markdown files into cells and allow molten to use execute
      'jmbuhr/otter.nvim', -- Enabling LSP in markdown
      'GCBallesteros/jupytext.nvim', -- Automatic conversion of buffers on open and close
    },
    build = ':UpdateRemotePlugins',
    init = function()
      vim.g.molten_image_provider = 'image.nvim'
      vim.g.molten_output_win_max_height = 20
    end,
    config = function()
      require('otter').setup {}
      require('jupytext').setup { -- Casting notebooks as markdown files
        style = 'markdown',
        output_extension = 'md',
        force_ft = 'markdown',
      }
      require('quarto').setup { -- Setting up quarto to run python with molten
        codeRunner = {
          enable = true,
          ft_runners = {
            python = 'molten',
          },
        },
      }

      -- Common settings for all REPL related functions
      vim.keymap.set('n', '<leader>mi', function()
        local conda_env = os.getenv 'CONDA_DEFAULT_ENV'
        if conda_env == nil then
          vim.cmd 'MoltenInit'
          return
        else
          vim.cmd('MoltenInit ' .. conda_env)
        end
      end, { silent = true, desc = '[M]olten [I]nitialize' })
      vim.keymap.set('n', '<leader>mel', ':MoltenEvaluateLine<CR>', { silent = true, desc = '[M]olten [E]valuate [L]ine' })
      vim.keymap.set('v', '<leader>mev', ':<C-u>MoltenEvaluateVisual<CR>gv', { silent = true, desc = '[M]olten [E]valuate [V]isual' })
      vim.keymap.set('n', '<leader>moh', ':MoltenHideOutput<CR>', { silent = true, desc = '[M]olten [O]utput [H]ide' })
      vim.keymap.set('n', '<leader>moe', ':noautocmd MoltenEnterOutput<CR>', { silent = true, desc = '[M]olten [O]utput [E]nter' })

      -- Additional settings for quarto cell splitting results
      local runner = require 'quarto.runner'
      vim.keymap.set('n', '<leader>mrc', runner.run_cell, { desc = '[M]olten [R]un [C]ell', silent = true })
      vim.keymap.set('n', '<leader>mra', runner.run_above, { desc = '[M]olten [R]un [a]bove', silent = true })
      vim.keymap.set('n', '<leader>mrA', runner.run_all, { desc = '[M]olten [R]un [A]ll', silent = true })
      vim.keymap.set('n', '<leader>mrl', runner.run_line, { desc = '[M]olten [R]un [l]ine', silent = true })
      vim.keymap.set('v', '<leader>mr', runner.run_range, { desc = '[M]olten [R]un visual', silent = true })
    end,
  },
  {
    '3rd/image.nvim', -- For image display
    -- dir = '/home/ensc/Homework/Personal/image.nvim',
    opts = {
      backend = 'ueberzug',
      max_width = 100,
      max_height_window_percentage = math.huge,
      max_width_window_percentage = math.huge,
      window_overlap_clear_enabled = true, -- toggles images when windows are overlapped
      window_overlap_clear_ft_ignore = { 'cmp_menu', 'cmp_docs', '' },
    },
  },
}
