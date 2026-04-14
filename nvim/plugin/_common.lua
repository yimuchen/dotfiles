-- While most plugin groups will have their configuration be managed within
-- their file, which-key will always need to be loaded in first, as this is how
-- we define keybinds in other files
vim.pack.add({ 'https://github.com/folke/which-key.nvim' })
local wk = require('which-key')
wk.setup({ preset = 'helix' })
wk.add({
  {
    '<leader>?',
    function()
      require('which-key').show { global = true }
    end,
    desc = 'Keymaps explorer',
  },
  { 'g',                group = 'Goto' },
  -- Common aliases for starting the command prompt with exiting prefixes
  { '<leader>x',        ':lua ',                          desc = 'Starting lua executor' },
  { '<leader>c',        ':! ',                            desc = 'Starting command executor' },
  { '<leader><leader>', function() vim.cmd("source") end, desc = "Reload configuration" },
  -- Moving selection up and down
  -- Stolen from theprimeagen: https://github.com/ThePrimeagen/init.lua/blob/master/lua/theprimeagen/remap.lua
  { "K",                ":m '<-2<CR>gv=gv",               desc = 'Move selection up',           mode = 'v' },
  { 'J',                ":m '>+1<CR>gv=gv",               desc = 'Move selection down',         mode = 'v' },
  -- Pasting from the system clipboard
  { "<leader>p",        [["_dP]],                         desc = "Paste from system clipboard", mode = 'x' }

})

-- Color theme should start as soon as possible
vim.pack.add({
  'https://github.com/gbprod/nord.nvim',
  'https://github.com/nvim-tree/nvim-web-devicons',
})

-- Setting up the color scheme
require("nord").setup({ transparent = true, style = { functions = { italic = true } } })
vim.cmd.colorscheme("nord")


-- Tree sitter needs to be loaded for proper syntax highlighting
vim.pack.add({
  'https://github.com/nvim-treesitter/nvim-treesitter',
  'https://github.com/nvim-treesitter/nvim-treesitter-textobjects', -- For generating additional objects
})

-- Tree-sitter shenanigans update
local common_filetypes = {
  -- Main tool languages
  'c', 'cpp', 'python', 'lua',
  -- Web stuff
  "html", "css", "javascript", "jsdoc", "json", "tsx", "typescript", "sql",
  -- Documentation languages
  "git_config", "gitcommit", 'markdown', 'markdown_inline', 'query', 'nix' }
local treesitter = require("nvim-treesitter")

treesitter.setup { -- Setting up the treesitter plugin with custom text objects
  highlight = { enable = true, additional_vim_regex_highlighting = false },
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

-- Ensuring that the files syntax files are installed
for _, parser in ipairs(common_filetypes) do
  treesitter.install(parser)
end

-- Not every tree-sitter parser is the same as the filetype detected
-- So the patterns need to be registered more cleverly. This solution is taken from here:
-- https://mhpark.me/posts/update-treesitter-main/
local patterns = {}
for _, parser in ipairs(common_filetypes) do
  local parser_patterns = vim.treesitter.language.get_filetypes(parser)
  for _, pp in pairs(parser_patterns) do
    table.insert(patterns, pp)
  end
end
vim.api.nvim_create_autocmd('FileType', {
  pattern = patterns,
  callback = function() vim.treesitter.start() end,
})

vim.api.nvim_create_autocmd('PackChanged', { -- Automatically run TSUpdate when package is updated
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if name == 'nvim-treesitter' and kind == 'update' then
      if not ev.data.active then vim.cmd.packadd('nvim-treesitter') end
      vim.cmd('TSUpdate')
    end
  end
})
