local common = require "common"
local json = require "json"
local LrApplication = import "LrApplication"
local LrDialogs = import "LrDialogs"
local LrFunctionContext = import "LrFunctionContext"
local LrProgressScope = import "LrProgressScope"

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
    table.insert(result, common.dump_set(val, progress))
  end
  for _, val in ipairs(catalog:getChildCollections()) do
    if progress:isCanceled() then return end
    table.insert(result, common.dump_collection(val, progress))
  end

  -- save as JSON
  progress:setCaption("Saving dump as JSON")
  if progress:isCanceled() then return end
  fh:write(json.encode(result))
end)
