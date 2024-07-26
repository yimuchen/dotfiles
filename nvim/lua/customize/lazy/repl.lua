return {
  -- REPL/notebook interactions within vim
  {
    'benlubas/molten-nvim',
    version = '<2.0.0', -- Pinning this version for now
    dependencies = {
      -- '3rd/image.nvim', -- For image display
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

      -- Helper function to initialize molten
      local molten_init = function()
        local conda_env = os.getenv 'CONDA_DEFAULT_ENV'
        if conda_env == nil then
          vim.cmd 'MoltenInit'
          return
        else
          vim.cmd('MoltenInit ' .. conda_env)
        end
      end

      -- Common settings for all REPL related functions
      local wk = require 'which-key'
      local runner = require 'quarto.runner'
      wk.add {
        { '<leader>m', group = '[M]olten REPL processing' },
        { '<leader>mi', molten_init, desc = '[M]olten [I]nitialize', silent = true },
        { '<leader>me', ':MoltenEvaluateLine<CR>', desc = '[M]olten [E]valuate', mode = 'n', silent = true },
        { '<leader>me', ':<C-u>MoltenEvaluateVisual<CR>gv', desc = '[M]olten [E]valuate', mode = 'x', silent = true },

        { '<leader>mo', group = '[M]olten [O]utput' },
        { '<leader>moh', ':MoltenHideOutput<CR>', silent = true, desc = '[M]olten [O]utput [H]ide' },
        { '<leader>moe', ':noautocmd MoltenEnterOutput<CR>', silent = true, desc = '[M]olten [O]utput [E]nter' },

        { '<leader>mr', group = '[M]olten [R]un (with quarto)' },
        { '<leader>mrc', runner.run_cell, desc = '[M]olten [R]un [C]ell', silent = true },
        { '<leader>mra', runner.run_above, desc = '[M]olten [R]un [a]bove', silent = true },
        { '<leader>mrA', runner.run_all, desc = '[M]olten [R]un [A]ll', silent = true },
        { '<leader>mrl', runner.run_line, desc = '[M]olten [R]un [l]ine', silent = true },
        { '<leader>mr', runner.run_range, desc = '[M]olten [R]un visual', silent = true, mode = 'v' },
      }

      -- Additional settings for quarto cell splitting results
    end,
  },
  -- {
  --   '3rd/image.nvim', -- For image display
  --   -- dir = '/home/ensc/Homework/Personal/image.nvim',
  --   opts = {
  --     backend = 'kitty',
  --     rocks = {
  --       enable = false,
  --     },
  --     max_width = 100,
  --     max_height_window_percentage = math.huge,
  --     max_width_window_percentage = math.huge,
  --     window_overlap_clear_enabled = true, -- toggles images when windows are overlapped
  --     window_overlap_clear_ft_ignore = { 'cmp_menu', 'cmp_docs', '' },
  --   },
  -- },
}
