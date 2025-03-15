-- Common petting stuff
if vim.fn.executable 'harper-ls' then
  require('lspconfig').harper_ls.setup {}
end

-- Formatting methods
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'markdown' },
  callback = function()
    require('lspconfig').marksman.setup {}
    local node_path = vim.fn.getcwd() .. '/node_modules'
    if vim.fn.isdirectory(node_path) == 1 then
      -- Use prettier for markdown formatter for blog posts/site generators
      require('conform').formatters_by_ft.markdown = { 'npx_prettier' }
    else
      require('conform').formatters_by_ft.markdown = { 'mdformat' }
    end
  end,
})
