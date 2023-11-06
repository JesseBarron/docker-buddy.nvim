local M = {}

local api = vim.api
local win, buf

-- Builds a table of strings defining the border for the window
-- [
-- '╔' + '═' x number of columns in window width + '╗'
-- '║' + ' ' blank spaces for window width +       '║' --> rows like these are inserted to the table for the entire height of the table
-- '╚' + '═' x number of columns in window width + '╝' 
-- ]
local function build_border_lines(win_width, win_height)
  local border_lines = { '╔' .. string.rep('═', win_width) .. '╗' }
  local middle_line = '║' .. string.rep(' ', win_width) .. '║'

  for i = 1, win_height do
    table.insert(border_lines, middle_line)
  end

  table.insert(border_lines, '╚' .. string.rep('═', win_width) .. '╝')

  return border_lines
end

local function open_window()
  buf = api.nvim_create_buf(false, true)

  -- This is pretty much saying, when the buffer is no longer displayed
  -- wipe it from the buffer list, effectively removing it and it's contents
  api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')

  -- get dimensions
  local width = api.nvim_get_option("columns") ---> Gets the actual number of cursor positions on the x axis
  local height = api.nvim_get_option("lines")  ---> Gets teh actual number of row positions on the Y axis I'm not sure if it counts tabs, etc..

  -- calculate our floating window size
  -- The 0.8 is the percentage (80%) of the editor height we want to cover.
  -- subtracting 1 for top and bottom padding
  local win_height = math.ceil(height * 0.8 - 1)
  local win_width = math.ceil(width * 0.8)

  -- Here we find where to position the window by finding the
  -- ammount of rows that are not being taken up by the window (difference)
  -- This value would position the window such that the buttom of it will
  -- touch the bottom of the editor.
  -- If we split the value in half, then the ammount of top and bottom
  -- space will be even around the window
  local row = math.ceil((height - win_height) / 2 - 1)
  -- Same principle but for left and right space around the window
  local col = math.ceil((width - win_width) / 2)

  -- set some options
  local opts = {
    style = "minimal",   --> removes lines, highlights, and spelling errors in the window
    relative = "editor", -->  Calculates values starting from the top-left corner of the editor
    width = win_width,
    height = win_height,

    -- Together these values find a point from the top-left corner of the editor
    row = row, --> which row to position the window
    col = col  --> at which column to position the window
  }

  local border_opts = {
    style = 'minimal',
    relative = 'editor',
    -- Make the height and width slightly taller and wider
    width = win_width + 2,
    height = win_height + 2,

    -- Position slightly to the top left of the window, so it's not overlapped by it 
    row = row - 1,
    col = col - 1
  }

  local border_buf = api.nvim_create_buf(false, true)
  local border_lines = build_border_lines(win_width, win_height)

  api.nvim_buf_set_lines(border_buf, 0, -1, false, border_lines)

  local border_win = api.nvim_open_win(border_buf, true, border_opts)
  -- First argument - buffer number
  -- second argument - whether the window should be focused
  -- third are display options
  win = api.nvim_open_win(buf, true, opts)

  -- Creates a listener basically saying
  -- When a buffer is wiped, execute "silent bwipeout! <border_buf>" close the border buffer too
  api.nvim_command('au BufWipeout <buffer> exe "silent bwipeout! "'..border_buf)
end

-- TODO: Move this into it's own file that makes use of this UI modlue
local function update_view()
  local running_containers = vim.fn.systemlist('docker container ls --format "{{.ID}} {{.Names}} {{.Status}}"')

  for k, _ in pairs(running_containers) do
    running_containers[k] = '  ' ..running_containers[k]
  end

  api.nvim_buf_set_lines(buf, 0, -1, false, running_containers)
end

open_window()
update_view()
