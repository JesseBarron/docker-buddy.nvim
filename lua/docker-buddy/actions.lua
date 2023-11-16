local UI = require('docker-buddy.ui')

local api = vim.api
local M = {}

local buf

-- Shape of table
-- {
-- "ID"= <container id>
-- "Names"= <name of the container>
-- }
local function getRunningContainters()
  local containers = {}
  local containerStringList =  vim.fn.systemlist("docker container ls --format='{{json .}}'") 

  for _, containerJson in pairs(containerStringList) do
    local containerTable = vim.json.decode(containerJson)
    table.insert(containers, {
      ID = containerTable['ID'],
      Names = containerTable['Names']
    })
  end

  return containers
end

local function findContainer(containerIdentifier)
  local containers = getRunningContainters()

  P(containers)
end


findContainer()
