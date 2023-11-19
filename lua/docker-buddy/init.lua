local Actions = require'docker-buddy.actions'
local UI = require'docker-buddy.ui'
local api = vim.api

local function set_all_buffer_keymaps(buf)
  api.nvim_buf_set_keymap(buf, 'n', 'R', "<Cmd>lua require('docker-buddy.actions').executeActionOnCurrentLine('restart')<CR>", {})
  api.nvim_buf_set_keymap(buf, 'n', 'U', "<Cmd>lua require('docker-buddy.actions').executeActionOnCurrentLine('unpause')<CR>", {})
  api.nvim_buf_set_keymap(buf, 'n', 'P', "<Cmd>lua require('docker-buddy.actions').executeActionOnCurrentLine('pause')<CR>", {})
  api.nvim_buf_set_keymap(buf, 'n', 'E', "<Cmd>lua require('docker-buddy.actions').executeActionOnCurrentLine('connect')<CR>", {})
end

-- Create A Few Commads
vim.api.nvim_create_user_command('DocBudRestart', function(args)
  P(args)
end, {
    nargs = "*"
})

vim.api.nvim_create_user_command('DockerBuddy', function ()
  local buf = UI.open_window()
 set_all_buffer_keymaps(buf)
  UI.update_view(Actions.getRunningContainters())
end, {})

-- set keybind to open the tool.
vim.api.nvim_set_keymap('n', '<leader>o', "<Cmd>DockerBuddy<cr>", {})

