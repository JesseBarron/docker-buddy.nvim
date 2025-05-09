local M = {}

function M.getRunningContainters()
	local containers = {}
	local containerStringList = vim.fn.systemlist("docker container ls --format='{{json .}}'")

	for _, containerJson in pairs(containerStringList) do
		local containerTable = vim.json.decode(containerJson)
		table.insert(containers, {
			ID = containerTable["ID"],
			Names = containerTable["Names"],
			State = containerTable["State"],
			Status = containerTable["Status"],
			Image = containerTable["Image"],
			Ports = containerTable["Ports"],
		})
	end

	return containers
end

function M.extractContainerIDFromCurrentLine()
	return vim.split(vim.trim(vim.api.nvim_get_current_line()), " ")[1]
end

local function findContainer(containerIdentifier)
	local containers = M.getRunningContainters()
	for _, container in pairs(containers) do
		if container["Names"] == containerIdentifier or container["ID"] == containerIdentifier then
			return container
		end
	end
	error('Container "' .. containerIdentifier .. '" not found', 1)
end

local function findContainerAndExecuteCommand(containerIdentifier, action)
	local success, result = pcall(findContainer, containerIdentifier)

	if not success then
		return print(result)
	end

	if action == "connect" then
		return M.connectToContainer(containerIdentifier)
	end

	local containerId = result["ID"]
	local resetResult = vim.fn.system("docker container " .. action .. " " .. containerId)

	if string.find(resetResult, "Error") then
		print(resetResult)
	else
		print("Successfully " .. action .. " Container: " .. containerIdentifier)
	end
end

local UI = require("docker-buddy.ui")
function M.executeActionOnCurrentLine(action)
	local containerId = M.extractContainerIDFromCurrentLine()
	findContainerAndExecuteCommand(containerId, action)
	UI.update_view(M.getRunningContainters())
end

function M.connectToContainer(containerIdentifier)
	if not pcall(findContainer, containerIdentifier) then
		return print("Container '" .. containerIdentifier .. "' not found")
	end

	local command = "docker exec -it " .. containerIdentifier .. " bash"

	local width = vim.api.nvim_get_option_value("columns", {}) ---> Gets the actual number of cursor positions on the x axis
	local height = vim.api.nvim_get_option_value("lines", {}) ---> Gets teh actual number of row positions on the Y axis I'm not sure if it counts tabs, etc..

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

	local buf = vim.api.nvim_get_current_buf()
	vim.api.nvim_buf_set_option(buf, "buftype", "terminal")

	-- local term_win = vim.api.nvim_open_win(
	-- 	buf,
	-- 	true,
	-- 	{ relative = "editor", width = win_width, height = win_height, row = row, col = col }
	-- )

	local term_chan = vim.api.nvim_open_term(buf, {})

	vim.api.nvim_chan_send(term_chan, command .. "\n")
end

-- TODO:
-- Add legend to the floating window
-- - Implement tests
return M
