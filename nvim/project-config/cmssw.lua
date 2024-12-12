local cmssw_path = {}
local id = vim.fn.jobstart({ '_cmssw_src_path' }, {
  on_stderr = function(_, _, _) end,
  on_stdout = function(_, data, _)
    if data == nil or #data == 0 then
      return
    end
    vim.list_extend(cmssw_path, data)
  end,
  on_exit = function(_, _, _) end,
})
vim.fn.jobwait { id }
cmssw_path = cmssw_path[1] -- Getting the CMSSW source path

-- Clangd configurations
require('lspconfig')['clangd'].setup { -- CLANGD does not seem to work well with CMSSW?
  cmd = { '_cmsexec', 'clangd', '--compile-commands-dir=' .. cmssw_path .. '/../' },
  root_dir = function(_)
    return cmssw_path
  end,
  single_file_support = false,
}

-- Python LSP configurations
require('lspconfig')['pylsp'].setup {
  cmd = { '_cmsexec', 'pylsp' },
}

require('lspconfig')['ruff'].setup {
  cmd = { '_cmsexec', 'ruff', 'server', '--preview' },
}

-- Do *not* setup formatting for now. As CMSSW code is usually done in
-- collaboration with others That may *not* have formatting properly setup.
