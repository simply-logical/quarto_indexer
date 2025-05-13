-- capture the name searched for by require
local NAME = 'helper'

local HELPER = {}

--------------------- ARRAYS ---------------------

-- Check if an element is in a list
local function elementInList(element, list)
  for _, e in ipairs(list) do
    if e == element then
      return true
    end
  end
  return false
end
-- HELPER.elementInList = elementInList

--------------------- TABLES ---------------------

-- Print a table
local function printTable(_table)
  for k, v in pairs(_table) do
    print(k, v)
  end
end
HELPER.printTable = printTable

-- Check if a key is in a table
local function keyInTable(key, _table)
  for _, k in ipairs(_table) do  -- pairs()
    if k == key then
      return true
    end
  end
  return false
end
-- HELPER.keyInTable = keyInTable

-- Get length of a table (number of keys)
local function tableLength(_table)
  local count = 0
  for _ in pairs(_table) do count = count + 1 end
  return count
end
HELPER.tableLength = tableLength

-- Get a list with keys of a table
local function tableKeys(_table)
  local keys = {}
  -- local count = 1
  for k, _ in pairs(_table) do
    -- keys[n] = k
    -- count = count + 1
    table.insert(keys, k)
  end
  return keys
end
-- HELPER.tableKeys = tableKeys

-- Validate keys of a table
local function validateTableKeys(allowedKeys, _table)
  if tableLength(_table) == 0 then
    return nil
  end

  keys = tableKeys(_table)

  wrongKeys = {}
  for _, key in ipairs(keys) do
    if not elementInList(key, allowedKeys) then
      table.insert(wrongKeys, key)
    end
  end

  if tableLength(wrongKeys) ~= 0 then
    error('Extension *indexer*: the following keys are not allowed: ' ..
          table.concat(wrongKeys, ', ') .. '.')
  end
end
HELPER.validateTableKeys = validateTableKeys

-- Inject elements from one table into another
local function embedTable(baseTable, tableToEmbed)
  if tableLength(tableToEmbed) == 0 then
    return baseTable
  end

  for _, v in ipairs(tableToEmbed) do
    table.insert(baseTable, v)
  end

  return baseTable
end
HELPER.embedTable = embedTable

return HELPER
