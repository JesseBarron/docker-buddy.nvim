local UI = {}
local api = vim.api
local buf
local win

function UI.open_window()
	buf = api.nvim_create_buf(false, true)

	-- get widnow dimensions
	local width = api.nvim_get_option_value("columns", {}) ---> Gets the actual number of cursor positions on the x axis
	local height = api.nvim_get_option_value("lines", {}) ---> Gets teh actual number of row positions on the Y axis I'm not sure if it counts tabs, etc..

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

	win = api.nvim_open_win(buf, true, {
		relative = "editor",
		width = win_width,
		height = win_height,
		row = row,
		col = col,
		style = "minimal",
		border = "rounded",
		title = "Yo",
		title_pos = "center",
	})

	return buf
end

function UI.update_view(running_containers)
	api.nvim_set_option_value("modifiable", true, { buf = buf })
	local container_lines = {}
	local cursor_pos = api.nvim_win_get_cursor(win)

	api.nvim_buf_set_lines(buf, 0, -1, false, { "  ID  Names  State  Status  Image  Ports" })
	for _, c in pairs(running_containers) do
		table.insert(
			container_lines,
			"  "
				.. c["ID"]
				.. "  "
				.. c["Names"]
				.. "  "
				.. c["State"]
				.. "  "
				.. c["Status"]
				.. "  "
				.. c["Image"]
				.. "  "
				.. c["Ports"]
		)
	end

	api.nvim_buf_set_lines(buf, 1, -1, false, container_lines)
	api.nvim_win_set_cursor(win, cursor_pos)
	api.nvim_set_option_value("modifiable", false, { buf = buf })
end

return UI
