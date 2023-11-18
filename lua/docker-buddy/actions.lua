local Terminal = require'toggleterm.terminal'.Terminal
local M = {}

-- Shape of table
-- {
-- "ID"= <container id>
-- "Names"= <name of the container>
-- }
function M.getRunningContainters()
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
  local containers = M.getRunningContainters()
  for _,container in pairs(containers) do
    if container['Names'] == containerIdentifier or container['ID'] == containerIdentifier then
      return container
    end
  end
  error('Container "'.. containerIdentifier ..'" not found', 1)
end

local function findContainerAndExecuteCommand(containerIdentifier, operation)
  local success, result = pcall(findContainer, containerIdentifier)

  if not success then
    return print(result)
  end

  local containerId = result["ID"]
  local resetResult = vim.fn.system("docker container "..operation.." "..containerId)

  if string.find(resetResult, 'Error') then
    print(resetResult)
  else
    print("Successfully "..operation.." Container: "..containerIdentifier)
  end
end

function M.restartContainer(containerIdentifier)
  findContainerAndExecuteCommand(containerIdentifier, 'restart')
end

function M.pauseContainer(containerIdentifier)
  findContainerAndExecuteCommand(containerIdentifier, 'pause')
end

function M.unpauseContainer(containerIdentifier)
  findContainerAndExecuteCommand(containerIdentifier, 'unpause')
end

function M.connectToContainer(containerIdentifier)
  if not pcall(findContainer, containerIdentifier) then
    return print("Container '"..containerIdentifier.."' not found")
  end

  local command = 'docker exec -it '..containerIdentifier..' bash'
  local term = Terminal:new({
    cmd=command
  })

  term:toggle()
end
-- M.connectToContainer('3a82c4e92a0e')


-- TODO:
-- - Enhance GUI with buffer keybinds, legends, and user input.
-- - After that work on updating UI with icons for paused running, ect...
return M
