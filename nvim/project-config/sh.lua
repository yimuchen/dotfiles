-- Additional methods for formatting (Use spaces rather than tabs)
local conform = require 'conform'
conform.formatters.shfmt = {
  prepend_args = function()
    return { '-i', '3' }
  end,
}
conform.formatters_by_ft.sh = { 'shfmt' }
