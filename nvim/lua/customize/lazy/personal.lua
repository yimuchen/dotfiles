local base_dir = vim.env.HOME .. '/.config/nvim-custom/plugins/'
local return_list = {}

local add_local_plugin = function(name, opt)
  if vim.loop.fs_stat(base_dir .. name) ~= nil then
    opt.dir = base_dir .. name
    table.insert(return_list, opt)
  end
end

add_local_plugin('rsync', {
  dependencies = { 'rcarriga/nvim-notify' },
  config = function()
    require('rsync').setup {}
  end,
})
add_local_plugin('modexec', {
  config = function()
    local modexec = require 'modexec'
    require('modexec').setup {
      detect = function()
        return {
          cmssw = modexec.env.cmssw(),
          apptainer = modexec.env.apptainer(),
        }
      end,
      auto_switch = true,
    }
  end,
})

return return_list
