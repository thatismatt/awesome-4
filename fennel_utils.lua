local function number_3f(x)
  return (type(x) == "number")
end
local function string_3f(x)
  return (type(x) == "string")
end
local function table_3f(x)
  return (type(x) == "table")
end
local function userdata_3f(x)
  return (type(x) == "userdata")
end
local function inc(i)
  return (i + 1)
end
local function dec(i)
  return (i - 1)
end
local function iter__3etable(it)
  local t = {}
  for k, v in it do
    t[k] = v
  end
  return t
end
local function map(f, tbl)
  local r = {}
  for k, v in pairs(tbl) do
    r[k] = f(v)
  end
  return r
end
local function filter(f, tbl)
  local r = {}
  for k, v in pairs(tbl) do
    if f(v) then
      r[k] = v
    end
  end
  return r
end
local function remove(f, tbl)
  local r = {}
  for k, v in pairs(tbl) do
    if not f(v) then
      r[k] = v
    end
  end
  return r
end
local function keys(tbl)
  local r = {}
  for k, v in pairs(tbl) do
    table.insert(r, k)
  end
  return r
end
local function vals(tbl)
  local r = {}
  for k, v in pairs(tbl) do
    table.insert(r, v)
  end
  return r
end
local function first(tbl)
  local _, v = next(tbl)
  return v
end
local function second(tbl)
  local k, v1 = next(tbl)
  local _, v2 = next(tbl, k)
  return v2
end
local function nth(n, tbl)
  local n0 = n
  local k = nil
  while (n0 > 0) do
    k = next(tbl, k)
    n0 = dec(n0)
  end
  local _, v = next(tbl, k)
  return v
end
local function join(sep, tbl)
  local function _0_()
    if tbl then
      return {sep, tbl}
    else
      return {"", sep}
    end
  end
  local _1_ = _0_()
  local sep0 = _1_[1]
  local tbl0 = _1_[2]
  return table.concat(vals(tbl0), (sep0 or ""))
end
local function range(from, to, step)
  local step0 = nil
  if number_3f(step) then
    step0 = step
  else
    step0 = 1
  end
  local function _1_()
    if number_3f(to) then
      return {from, to}
    else
      return {0, from}
    end
  end
  local _2_ = _1_()
  local from0 = _2_[1]
  local to0 = _2_[2]
  local r = {}
  for i = from0, to0, step0 do
    table.insert(r, i)
  end
  return r
end
local function capitalize(str)
  return str:gsub("^%l", string.upper)
end
local function seconds__3eduration(secs)
  if (secs > 3600) then
    return string.format("%.1f hrs", (secs / 3600))
  elseif (secs > 60) then
    return string.format("%.1f mins", (secs / 60))
  else
    return string.format("%.1f secs", secs)
  end
end
local function bytes__3estring(bytes)
  return join(map(string.char, bytes))
end
return {["bytes->string"] = bytes__3estring, ["iter->table"] = iter__3etable, ["number?"] = number_3f, ["seconds->duration"] = seconds__3eduration, ["string?"] = string_3f, ["table?"] = table_3f, ["userdata?"] = userdata_3f, capitalize = capitalize, dec = dec, filter = filter, first = first, inc = inc, join = join, keys = keys, map = map, nth = nth, range = range, remove = remove, second = second, vals = vals}
