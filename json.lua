-- Tiny JSON Encoder in Pure Lua
--
-- @copyright 2020 LiosK
-- @license Apache-2.0

local json = { _VERSION = "1.0.1" }

function json.encode(value)
  local encoder = json["encode_" .. type(value)] or json.encode_other
  return encoder(value)
end

function json.encode_nil(value)
  return "null"
end

function json.encode_boolean(value)
  return tostring(value)
end

function json.encode_number(value)
  if value ~= value or math.abs(value) >= math.huge then
    error("unsupported number value: " .. tostring(value))
  end
  return tostring(value)
end

local memo, special_chars = {}, {}

for c = 0, 0x1f do
  special_chars[string.char(c)] = string.format("\\u%04x", c)
end

special_chars["\b"] = "\\b"
special_chars["\f"] = "\\f"
special_chars["\n"] = "\\n"
special_chars["\r"] = "\\r"
special_chars["\t"] = "\\t"
special_chars["\""] = "\\\""
special_chars["\\"] = "\\\\"

function json.encode_string(value)
  if memo[value] == nil then
    memo[value] = '"' .. value:gsub("[\x00-\x1f\"\\]", special_chars) .. '"'
  end
  return memo[value]
end

function json.encode_table(value)
  if next(value) == nil then
    return json.encode_empty_table(value)
  end

  local i = 1
  for _ in pairs(value) do
    if value[i] == nil then
      return json.encode_object(value)
    end
    i = i + 1
  end
  return json.encode_array(value)
end

function json.encode_empty_table(value)
  return "[]"
end

function json.encode_array(value)
  local result = {}
  for k, v in ipairs(value) do
    table.insert(result, json.encode(v))
  end
  return "[" .. table.concat(result, ",") .. "]"
end

function json.encode_object(value)
  local result = {}
  for k, v in pairs(value) do
    local str_key = json.encode_string(tostring(k))
    table.insert(result, str_key .. ":" .. json.encode(v))
  end
  return "{" .. table.concat(result, ",") .. "}"
end

function json.encode_other(value)
  error("unsupported type: " .. type(value))
end

return json
