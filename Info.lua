-- Photo Info Dumper Lightroom Plug-in
--
-- @copyright 2020 LiosK
-- @license: Apache-2.0
return {
  LrSdkVersion = 10.0,
  LrToolkitIdentifier = "net.liosk.lightroom.PhotoInfoDumper",
  LrPluginName = "Photo Info Dumper",
  LrPluginInfoUrl = "https://github.com/LiosK/PhotoInfoDumper.lrplugin",
  VERSION = {
    major = 0,
    minor = 0,
    revision = 1,
  },
  LrLibraryMenuItems = {
    {
      title = "Dump Metadata for All Photos...",
      file = "DumpMetadataAll.lua",
    },
    {
      title = "Dump Metadata for Selected Photos...",
      file = "DumpMetadataSelected.lua",
    },
    {
      title = "Dump Collection Contents...",
      file = "DumpCollections.lua",
    },
  },
}
