local Terminal = require'toggleterm.terminal'.Terminal
local M = {}

function M.getRunningContainters()
  local containers = {}
  local containerStringList =  vim.fn.systemlist("docker container ls --format='{{json .}}'")

  for _, containerJson in pairs(containerStringList) do
    local containerTable = vim.json.decode(containerJson)
    table.insert(containers, {
      ID = containerTable['ID'],
      Names = containerTable['Names'],
      State = containerTable['State'],
      Status = containerTable['Status'],
      Image = containerTable['Image'],
      Ports = containerTable['Ports']
    })
  end

  return containers
end

function M.extractContainerIDFromCurrentLine()
  return vim.split(vim.trim(vim.api.nvim_get_current_line()), ' ')[1]
end

local function findContainer(containerIdentifier)
  local containers = M.getRunningContainters()
  for _,container in pairs(containers) do
    if container['Names'] == containerIdentifier or container['ID'] == containerIdentifier then
      return container
    end
  end
  error('Container "'.. containerIdentifier ..'" not found', 1)
end

local function findContainerAndExecuteCommand(containerIdentifier, action)
  local success, result = pcall(findContainer, containerIdentifier)

  if not success then
    return print(result)
  end

  if action == 'connect' then
    return M.connectToContainer(containerIdentifier)
  end

  local containerId = result["ID"]
  local resetResult = vim.fn.system("docker container "..action.." "..containerId)

  if string.find(resetResult, 'Error') then
    print(resetResult)
  else
    print("Successfully "..action.." Container: "..containerIdentifier)
  end
end

local UI = require('docker-buddy.ui')
function M.executeActionOnCurrentLine(action)
 local containerId =  M.extractContainerIDFromCurrentLine()
  findContainerAndExecuteCommand(containerId, action)
  UI.update_view(M.getRunningContainters())
end

function M.connectToContainer(containerIdentifier)
  if not pcall(findContainer, containerIdentifier) then
    return print("Container '"..containerIdentifier.."' not found")
  end

  local command = 'docker exec -it '..containerIdentifier..' bash'
  local term = Terminal:new({
    cmd=command
  })

  term:open()
end

-- TODO:
-- Add legend to the floating window
-- - Implement tests
return M

