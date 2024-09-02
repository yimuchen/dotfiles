local starter = require 'mini.starter'

-- Custom function for finding all git directories listed under
local find_git_dirs = function()
  local excludes = {
    'TEMP',
    'ArchConfig/package',
    'ArchConfig/UnixConfig',
  }
  local cmd = "find ~/*/ -name '.git' -type d" --Find all .git instances in visible directories
  for _, ex in ipairs(excludes) do
    cmd = cmd .. " -not -path '*/" .. ex .. "/*'  "
  end
  local pipe = assert(io.popen(cmd, 'r'))
  local stdout = assert(pipe:read '*a')
  pipe:close()

  local return_list = {}
  for str in string.gmatch(stdout, '([^%s]+)') do
    table.insert(return_list, vim.fs.dirname(str))
  end

  return return_list
end

-- Ordering git according to most recent edit in directory
local order_git_dirs = function(git_dirs)
  local time = {}
  for _, dir in ipairs(git_dirs) do
    local cmd = 'find  ' .. dir .. "  -type f  -printf '%T@\n' " -- List all directories
    cmd = cmd .. '| sort -n  | tail -n 1' -- getting final entry via CLI sorting
    local pipe = assert(io.popen(cmd, 'r'))
    local stdout = assert(pipe:read '*a')
    pipe:close()

    table.insert(time, { dir, tonumber(stdout) })
  end

  table.sort(time, function(a, b) -- Sorting by second entry
    return a[2] > b[2]
  end)

  local return_list = {}
  for _, dir in ipairs(time) do
    table.insert(return_list, dir[1])
  end

  return return_list
end

local start_git_dirs = (function()
  local list = {}
  for _ = 1, 10 do
    table.insert(list, {
      name = 'Searching...',
      action = '',
      section = 'Recent projects ',
    })
  end

  -- Stop immediately if not running a mini-starter page
  if vim.bo.filetype ~= 'ministarter' then
    return list
  end

  vim.schedule(function()
    local homedir = os.getenv 'HOME'
    local git_dir_list = find_git_dirs()
    git_dir_list = order_git_dirs(git_dir_list)
    for index, dir in ipairs(git_dir_list) do
      if index > 10 then
        break
      end
      list[index] = {
        name = '📁 ' .. dir:gsub(homedir, '~'),
        action = 'cd ' .. dir .. ' | Oil ' .. dir,
        section = 'Recent projects ',
      }
    end
    MiniStarter.refresh()
  end)

  return function()
    return list
  end
end)()

starter.setup {
  evaluate_single = true,
  header = 'Welcome to Neovim!',
  items = {
    starter.sections.builtin_actions(),
    starter.sections.recent_files(5, true),
    start_git_dirs,
  },
}
