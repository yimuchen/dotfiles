require('rsync').setup {
  fugitive_sync = false,
  sync_on_save = false,
  project_config_path = './.rsync.toml',
  on_exit = function(code, command) end,
  on_stderr = function(code, command) end,
}
