-- Defining the texlab settings
require('lspconfig').texlab.setup {} -- Default setup for texlab
require('lspconfig').ltex.setup {}

-- Formatting methods
require('conform').formatters_by_ft.tex = { 'latexindent' }
