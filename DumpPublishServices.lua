local common = require "common"
local json = require "json"
local LrApplication = import "LrApplication"
local LrDialogs = import "LrDialogs"
local LrFunctionContext = import "LrFunctionContext"
local LrProgressScope = import "LrProgressScope"

LrFunctionContext.postAsyncTaskWithContext("DumpPublishServices", function(context)
  LrDialogs.attachErrorDialogToFunctionContext(context)

  -- show save dialog and open file to write
  local fh = common.open_file()
  if fh == nil then return end
  context:addCleanupHandler(function() fh:close() end)

  local progress = LrProgressScope{title = "Dumping publish service collections"}
  progress:attachToFunctionContext(context)

  local result = {}
  local catalog = LrApplication.activeCatalog()
  for _, publishService in ipairs(catalog:getPublishServices(nil)) do
    local result_ps = {
      type = publishService:type(),
      name = publishService:getName(),
      plugin = publishService:getPluginId(),
      children = {},
    }
    for _, val in ipairs(publishService:getChildCollectionSets()) do
      if progress:isCanceled() then return end
      table.insert(result_ps.children, common.dump_set(val, progress))
    end
    for _, val in ipairs(publishService:getChildCollections()) do
      if progress:isCanceled() then return end
      table.insert(result_ps.children, common.dump_collection(val, progress))
    end
    table.insert(result, result_ps)
  end

  -- save as JSON
  progress:setCaption("Saving dump as JSON")
  if progress:isCanceled() then return end
  fh:write(json.encode(result))
end)
