local mini_ai = require 'mini.ai'

-- Adding custom selection scopes using treesitter
local spec_treesitter = require('mini.ai').gen_spec.treesitter
-- Does this currently not work??
mini_ai.config.custom_textobjects['C'] = spec_treesitter { a = '@comment.outer', i = '@comment.inner' }
mini_ai.config.custom_textobjects['F'] = spec_treesitter { a = '@function.outer', i = '@function.inner' }

