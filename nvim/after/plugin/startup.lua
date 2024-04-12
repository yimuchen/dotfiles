local header = {
  type = 'text',
  oldfiles_directory = false,
  align = 'center',
  fold_section = false,
  title = 'Header',
  margin = 5,
  content = {
    ' ███╗   ██╗ ███████╗ ██████╗  ██╗   ██╗ ██╗ ███╗   ███╗',
    ' ████╗  ██║ ██╔════╝██╔═══██╗ ██║   ██║ ██║ ████╗ ████║',
    ' ██╔██╗ ██║ █████╗  ██║   ██║ ██║   ██║ ██║ ██╔████╔██║',
    ' ██║╚██╗██║ ██╔══╝  ██║   ██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║',
    ' ██║ ╚████║ ███████╗╚██████╔╝  ╚████╔╝  ██║ ██║ ╚═╝ ██║',
    ' ╚═╝  ╚═══╝ ╚══════╝ ╚═════╝    ╚═══╝   ╚═╝ ╚═╝     ╚═╝',
  },
  highlight = 'Statement',
  default_color = '',
  oldfiles_amount = 0,
}

local common_commands = {
  type = 'mapping',
  oldfiles_directory = false,
  align = 'center',
  fold_section = false,
  title = 'Basic Commands',
  margin = 0,
  content = {
    { ' Find File   ', 'Telescope find_files', '<leader>sf' },
    { ' Find Word   ', 'Telescope live_grep', '<leader>sg' },
    { ' Find keybind', 'Telescope keymaps', '<leader>sk' },
    { ' Recent Files', 'Telescope oldfiles', '<leader>s.' },
    { ' File Browser', 'Oil', '<leader>bv' },
  },
  highlight = 'String',
  default_color = '',
  oldfiles_amount = 0,
}

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
  for index, dir in ipairs(time) do
    if index > 10 then
      break
    end
    table.insert(return_list, dir[1])
  end

  return return_list
end

local find_projects = function()
  local git_dirs = find_git_dirs()
  git_dirs = order_git_dirs(git_dirs)

  local make_entry = function(dir, idx)
    return { '📁 ' .. dir, 'cd ' .. dir .. ' | Oil ' .. dir, '<leader>open' .. tostring(idx) }
  end
  local return_list = {}
  for idx, dir in ipairs(git_dirs) do
    table.insert(return_list, make_entry(dir, idx))
  end
  return return_list
end

local recent_dirs = {
  type = 'mapping',
  oldfiles_directory = false,
  align = 'center',
  fold_section = false,
  title = 'Recent projects',
  margin = 1,
  content = {},
  highlight = 'String',
  oldfiles_amount = 0,
}

local _colorcolumn_settings = vim.opt.colorcolumn

vim.api.nvim_create_autocmd('FileType', {
  pattern = { '*' },
  callback = function()
    if vim.bo.filetype == 'startup' then
      -- Only calling if the filestype startup
      recent_dirs.content = find_projects()
      vim.opt.colorcolumn = ''
    else
      -- Need to recover the settings when opening a new filetype (the set is
      -- always ran before the plugins after scripts so we know that this will
      -- be properly stored
      vim.opt.colorcolumn = _colorcolumn_settings
    end
  end,
})

local settings = {
  -- every line should be same width without escaped \
  header = header,
  -- name which will be displayed and command
  common = common_commands,
  --Recent projects
  recent = recent_dirs,

  clock = {
    type = 'text',
    content = function()
      local date = ' ' .. os.date '%y-%m-%d'
      local clock = ' ' .. os.date '%H:%M'
      return { date, clock, vim.api.nvim_buf_get_name(0) }
    end,
    oldfiles_directory = false,
    align = 'center',
    fold_section = false,
    title = '',
    margin = 5,
    highlight = 'TSString',
    default_color = '#FFFFFF',
    oldfiles_amount = 10,
  },
  content = { 'startup.nvim', vim.api.nvim_buf_get_name(0) },

  options = {
    mapping_keys = true,
    cursor_column = 0.5,
    empty_lines_between_mappings = false,
    disable_statuslines = true,
    paddings = { 5, 3, 3, 0 },
  },
  mappings = {
    execute_command = '<CR>',
    open_file = 'o',
    open_file_split = '<c-o>',
    open_section = '<TAB>',
    open_help = '?',
  },
  colors = {
    background = '#1f2227',
    folded_section = '#56b6c2',
  },
  parts = { 'header', 'common', 'clock', 'recent' },
}

require('startup').setup(settings)
