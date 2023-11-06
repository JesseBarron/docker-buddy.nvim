local api = vim.api
local M = {}

-- Create a window possibly using pop?

-- local function create_window()
--   -- What do I need in order to make a window
--   -- TODO: Get width and height from nvim if not config..
--   local width = 70
--   local height = 20
--   local borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }

--   local bufnr = vim.api.nvim_create_buf(false, false)

--   local docker_win_id, win = popup.create(bufnr, {
--     title = "Docker Buddy",
--     line = math.floor(((vim.o.lines - height) / 2) - 1),
--     col = math.floor((vim.o.columns - width) / 2),
--     minwidth = width,
--     minheight = height,
--     borderchars = borderchars
--   })

--   vim.api.nvim_win_set_option(
--       win.border.win_id,
--       "winhl",
--       "Normal:HarpoonBorder"
--   )

--   return {
--     win_id = docker_win_id,
--     bufrn = bufnr
--   }
-- end

local function open_window()
  buf = api.nvim_create_buf(false, true)

  -- This is pretty much saying, when the buffer is no longer displayed
  -- wipe it from the buffer list, effectively removing it and it's contents
  api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')

  -- get dimensions
  local width = api.nvim_get_option("columns") ---> Gets the actual number of cursor positions on the x axis
  local height = api.nvim_get_option("lines") ---> Gets teh actual number of row positions on the Y axis I'm not sure if it counts tabs, etc..

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
    style = "minimal", --> removes lines in the window
    relative = "editor", --> makes it so size and positioning are calculated relative to the editor grid
    width = win_width,
    height = win_height,

    -- Together these values find a point where the NW corner of the winow will be placed
    row = row, --> which row to position the window
    col = col --> at which column to position the window
  }

  -- First argument - buffer number
  -- second argument - whether the window should be focused
  -- third are display options
  win = api.nvim_open_win(buf, true, opts)
end



