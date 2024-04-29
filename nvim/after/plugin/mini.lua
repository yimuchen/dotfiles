local mini_ai = require 'mini.ai'

-- Adding custom selection scopes using treesitter
local spec_treesitter = require('mini.ai').gen_spec.treesitter
--- For comments we will be using the mini.comment to handle the block comments
mini_ai.config.custom_textobjects['F'] = spec_treesitter { a = '@function.outer', i = '@function.inner' }
mini_ai.config.custom_textobjects['C'] = spec_treesitter { a = '@code_cell.outer', i = '@code_cell.inner' }

