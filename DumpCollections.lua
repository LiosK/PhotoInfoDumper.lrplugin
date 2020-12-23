local common = require "common"
local json = require "json"
local LrApplication = import "LrApplication"
local LrDialogs = import "LrDialogs"
local LrFunctionContext = import "LrFunctionContext"
local LrProgressScope = import "LrProgressScope"

local function dump_collection(collection, progress)
  local result = {
    type = "collection",
    name = collection:getName(),
    photos = {},
  }

  progress:setCaption("Retrieving contents of " .. result.name)

  local photos = collection:getPhotos()
  local batch_raw = collection.catalog:batchGetRawMetadata(photos, {
    "uuid",
    "path",
    "isVirtualCopy",
  })

  for _, val in ipairs(photos) do
    table.insert(result.photos, batch_raw[val])
  end

  return result
end

local function dump_set(set, progress)
  local result = {
    type = "set",
    name = set:getName(),
    children = {},
  }

  for _, val in ipairs(set:getChildCollectionSets()) do
    if progress:isCanceled() then return result end
    table.insert(result.children, dump_set(val, progress))
  end
  for _, val in ipairs(set:getChildCollections()) do
    if progress:isCanceled() then return result end
    table.insert(result.children, dump_collection(val, progress))
  end

  return result
end

LrFunctionContext.postAsyncTaskWithContext("DumpCollections", function(context)
  LrDialogs.attachErrorDialogToFunctionContext(context)

  -- show save dialog and open file to write
  local fh = common.open_file()
  if fh == nil then return end
  context:addCleanupHandler(function() fh:close() end)

  local progress = LrProgressScope{title = "Dumping collection contents"}
  progress:attachToFunctionContext(context)

  local result = {}
  local catalog = LrApplication.activeCatalog()
  for _, val in ipairs(catalog:getChildCollectionSets()) do
    if progress:isCanceled() then return end
    table.insert(result, dump_set(val, progress))
  end
  for _, val in ipairs(catalog:getChildCollections()) do
    if progress:isCanceled() then return end
    table.insert(result, dump_collection(val, progress))
  end

  -- save as JSON
  progress:setCaption("Saving dump as JSON")
  if progress:isCanceled() then return end
  fh:write(json.encode(result))
end)
