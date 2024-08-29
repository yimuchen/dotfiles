-- Writing a custom rsync function that allows for files to be synced to
-- multiple hosts on save or by demand. The configuration file should be a json
-- file at the paths of either "<project_root>/.rsync.json" or "<project_root>/.nvim/rsync.json".
-- And should be in the following format:
--
-- {
--   "exclude" : ["List of file patterns to exclude from the uploads (can be omitted)"]
--   "exclude_file": ["List of files to get exclude patterns from (can be omitted)"]
--   "remotes" : [
--     {
--       "host": "name of ssh host",
--       "basedir": "path to the where the file will be stored",
--       "exclude": ["Additional list of file patterns to ignore for this host"],
--       "run_on_save": true/false (Flag of whether one should attempt to upload on file write)
--     }
--   ]
--}

-- Helper function for the common tenary operation
local _ternary = function(cond, T, F)
  if cond then
    return T
  else
    return F
  end
end

-- Helper function to unpack lists into something that can be easily
-- concatenated
local _extend = function(dest, src)
  if src == nil or #src == 0 then
    return dest
  end
  vim.list_extend(dest, src)
  return dest
end

local _unique = function(list)
  local return_lookup = {}
  for _, v in ipairs(list) do
    return_lookup[v] = true
  end
  local return_list = {}
  for k, _ in pairs(return_lookup) do
    table.insert(return_list, k)
  end
  return return_list
end

-- Given the root file, and the json_path file, convert the json configuration
-- into a common lua-table format of:
-- {
--    root_path = "absolute path of project root"
--    remote_hosts = { -- List of remote hosts, all options are expected to per host
--      {
--        host = "string of ssh host",
--        basedir = "path to store at remote host",
--        run_on_save = true/false flag to indicate whether the run should be executed per save
--        exclude = { "table",  "of", "exclude", "patterns" },
--        exclude_file = { "list", "of", "file", "containing", "exclude", "patterns"}
--      }
--    }
-- }
local parse_configuration = function(root_path, json_path)
  local json_table = vim.json.decode(io.open(json_path, 'r'):read '*all')
  local common_defaults = {
    exclude = {
      '.git/', -- Avoid version tracking mismatches
      '.git/*',
    },
    exclude_file = { '.gitignore' },
    run_on_save = false,
  }
  local return_table = {
    root_path = root_path,
    remote_hosts = {},
  }

  for _, remote in ipairs(json_table.remotes) do
    -- Skipping over malformed entries
    if remote.host == nil then
      vim.notify('Skipping over entry without [host]', vim.log.levels.WARN)
      goto continue
    end
    if remote.basedir == nil then
      vim.notify('Skipping over entry without [basedir]', vim.log.levels.WARN)
      goto continue
    end
    -- Expanding out so that everything is common (File pattern is
    -- automatically expanded at root of project path)
    local exclude = common_defaults.exclude
    exclude = _extend(exclude, json_table.exclude)
    exclude = _extend(exclude, remote.exclude)
    exclude = _unique(exclude)

    -- Exclude file should be evaluated from the root_path
    local exclude_file = common_defaults.exclude_file
    exclude_file = _extend(exclude_file, remote.exclude_file)
    exclude_file = _extend(exclude_file, json_table.exclude_file)
    exclude_file = _unique(exclude_file)
    for i, v in ipairs(exclude_file) do
      if v:find '^/' == nil then
        exclude_file[i] = root_path .. '/' .. v
      end
    end

    table.insert(return_table.remote_hosts, {
      host = remote.host,
      basedir = remote.basedir,
      exclude = exclude,
      exclude_file = exclude_file,
      run_on_save = _ternary((remote.run_on_save ~= nil), remote.run_on_save, common_defaults.run_on_save),
    })
    ::continue::
  end

  return return_table
end

-- Automatically get the configuration file, based on the directory structure
-- to find the base file
local get_rsync_config = function()
  -- Trying to find the rsync configuration in the base directory first
  local root_patterns = { '.git', '.clang-format', 'pyproject.toml', 'setup.py', '.nvim' }
  local root_dir = vim.fs.dirname(vim.fs.find(root_patterns, {
    upward = true,
    stop = vim.loop.os_homedir(),
    path = vim.fs.dirname(vim.api.nvim_buf_get_name(0)),
  })[1])
  -- Early exit if not in a project directory
  if root_dir == nil then
    return nil
  end
  -- Various file paths that we recognize:
  for _, path in ipairs { '.rsync.json', '.nvim/rsync.json' } do
    local find_path = root_dir .. '/' .. path
    if vim.fn.findfile(find_path) ~= '' then
      return parse_configuration(root_dir, find_path)
    end
  end

  -- Return an nil if the rsync.json is not found
  return nil
end

-- Simple function for performing string concatenation, similar to what is done
-- for python string.join
local _joinstr = function(list, delim)
  local return_str = ''
  for _, v in ipairs(list) do
    if return_str == '' then
      return_str = v
    else
      return_str = return_str .. delim .. v
    end
  end
  return return_str
end

local make_rsync_upload_commands = function(local_root, remote_config)
  -- For a given remote host configuration, return the rsync command to be ran
  --as a list of strings

  local exclude_tokens = {}
  for _, pattern in ipairs(remote_config.exclude) do
    table.insert(exclude_tokens, '--exclude=' .. pattern)
  end

  local cmd = {
    'rsync',
    '-a', -- # rsync in archive mode
    '-r', -- # Recrusive,
  }

  vim.list_extend(cmd, exclude_tokens)
  vim.list_extend(cmd, {
    '--exclude-from=' .. _joinstr(remote_config.exclude_file, ','),
    local_root .. '/',
    remote_config.host .. ':' .. remote_config.basedir,
  })

  return cmd
end

--- Summary
--  @param dry_run: If set to true, it will only print the rsync command that
--  will be excluded
--
--  @param auto_trigger: If set to true, only the entries with 'run_on_save'
--  set to true will be run (both dry_run and none dry_run will be disabled)
local run_rsync = function(dry_run, auto_trigger)
  local config = get_rsync_config()
  if config == nil then
    -- vim.notify_once('Cannot find valid configurations file', vim.log.levels.INFO)
    return
  end
  for _, remote_config in ipairs(config.remote_hosts) do
    if remote_config.run_on_save == true or auto_trigger == false then
      local cmd = make_rsync_upload_commands(config.root_path, remote_config)
      if dry_run then
        vim.notify('Target command [' .. _joinstr(cmd, ' ') .. ']', vim.log.levels.INFO, {
          timeout = 1000,
          title = 'Rsync Dry run',
        })
      else
        -- Setting up local variables for re-logging the output
        local stderr = {}
        local stdout = {}
        vim.fn.jobstart(cmd, {
          on_stderr = function(_, data, _)
            if data == nil or #data == 0 then
              return
            end
            vim.list_extend(stderr, data)
          end,
          on_stdout = function(_, data, _)
            if data == nil or #data == 0 then
              return
            end
            vim.list_extend(stdout, data)
          end,
          on_exit = function(_, code, _)
            if code ~= 0 then
              vim.notify(table.concat(stderr, '\n'), vim.log.levels.ERROR, {
                timeout = 1000,
                title = 'Error running rsync',
                icon = '',
              })
            else
              vim.notify(table.concat(stdout, '\n'), vim.log.levels.INFO, {
                timeout = 10000,
                title = 'Complete rsync to [' .. remote_config.host .. ']',
                icon = '',
              })
            end
          end,
        })
      end
    end
  end
end

-- Creating commands to be ran
vim.api.nvim_create_user_command('RsyncUploadDry', function()
  run_rsync(true, false)
end, {})
vim.api.nvim_create_user_command('RsyncUpload', function()
  run_rsync(false, false)
end, {})

-- Setting up the keymaps to run the rsync commands manually
vim.keymap.set('n', '<leader>pu', function()
  run_rsync(false, false)
end, { desc = '[P]roject [U]pload' })

-- Setting up the automatic command to run if the run_on_save flag is set for a
-- host configuration
vim.api.nvim_create_autocmd('BufWritePost', {
  callback = function(_)
    run_rsync(false, true)
  end,
})
