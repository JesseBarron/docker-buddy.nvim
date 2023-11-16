local UI = require('docker-buddy.ui')

local api = vim.api
local M = {}

local buf


local function findContainer(containerIdentifier)
  local containers =  vim.fn.system("docker container ls --format='{{json .}}'") 
  P(containers)
end

