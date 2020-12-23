local common = {}

-- Show save dialog and open file to write.
function common.open_file()
  local filename = import("LrDialogs").runSavePanel({
    title = "Choose a filename to save the metadata dump.",
    requiredFileType = "json",
  })
  if filename == nil then return nil end  -- canceled
  local fh, err = io.open(filename, "w")
  if fh == nil then error("Cannot write to the file: " .. err) end
  return fh
end

-- Prepare dump structure for photo metadata from Lightroom objects
function common.build_photo_dump(photos, batch_raw, batch_formatted)
  local function convert_LrPhoto_to_uuid(photo)
    if batch_raw[photo] ~= nil then return batch_raw[photo].uuid end
    return photo:getRawMetadata("uuid")
  end

  local result = {}
  for i, photo in ipairs(photos) do
    local r, f = batch_raw[photo], batch_formatted[photo]

    -- convert Lr objects to common values
    if r.masterPhoto ~= nil then
      r.masterPhoto = convert_LrPhoto_to_uuid(r.masterPhoto)
    end
    if r.topOfStackInFolderContainingPhoto ~= nil then
      r.topOfStackInFolderContainingPhoto = convert_LrPhoto_to_uuid(r.topOfStackInFolderContainingPhoto)
    end
    if r.stackInFolderMembers ~= nil then
      for k, v in ipairs(r.stackInFolderMembers) do
        r.stackInFolderMembers[k] = convert_LrPhoto_to_uuid(v)
      end
    end
    if r.virtualCopies ~= nil then
      for k, v in ipairs(r.virtualCopies) do
        r.virtualCopies[k] = convert_LrPhoto_to_uuid(v, rs)
      end
    end
    if r.keywords ~= nil then
      for k, v in ipairs(r.keywords) do
        r.keywords[k] = v:getName()
      end
    end

    result[r.uuid] = { raw = r, formatted = f }
  end
  return result
end

return common
