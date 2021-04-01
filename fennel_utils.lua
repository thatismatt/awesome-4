local fu = {}
fu["number?"] = function(x)
  return (type(x) == "number")
end
fu["string?"] = function(x)
  return (type(x) == "string")
end
fu["table?"] = function(x)
  return (type(x) == "table")
end
fu["userdata?"] = function(x)
  return (type(x) == "userdata")
end
fu.inc = function(i)
  return (i + 1)
end
fu.dec = function(i)
  return (i - 1)
end
fu["iter->table"] = function(it)
  local t = {}
  for k, v in it do
    t[k] = v
  end
  return t
end
fu.map = function(f, tbl)
  local r = {}
  for k, v in pairs(tbl) do
    r[k] = f(v)
  end
  return r
end
fu.filter = function(f, tbl)
  local r = {}
  for k, v in pairs(tbl) do
    if f(v) then
      r[k] = v
    end
  end
  return r
end
fu.remove = function(f, tbl)
  local r = {}
  for k, v in pairs(tbl) do
    if not f(v) then
      r[k] = v
    end
  end
  return r
end
fu.keys = function(tbl)
  local r = {}
  for k, v in pairs(tbl) do
    table.insert(r, k)
  end
  return r
end
fu.vals = function(tbl)
  local r = {}
  for k, v in pairs(tbl) do
    table.insert(r, v)
  end
  return r
end
fu.first = function(tbl)
  local _, v = next(tbl)
  return v
end
fu.second = function(tbl)
  local k, v1 = next(tbl)
  local _, v2 = next(tbl, k)
  return v2
end
fu.nth = function(n, tbl)
  local n0 = n
  local k = nil
  while (n0 > 0) do
    k = next(tbl, k)
    n0 = dec(n0)
  end
  local _, v = next(tbl, k)
  return v
end
fu.join = function(sep, tbl)
  local function _0_()
    if tbl then
      return {sep, tbl}
    else
      return {"", sep}
    end
  end
  local _let_0_ = _0_()
  local sep0 = _let_0_[1]
  local tbl0 = _let_0_[2]
  return table.concat(fu.vals(tbl0), (sep0 or ""))
end
fu.range = function(from, to, step)
  local step0
  if fu["number?"](step) then
    step0 = step
  else
    step0 = 1
  end
  local function _1_()
    if fu["number?"](to) then
      return {from, to}
    else
      return {0, from}
    end
  end
  local _let_0_ = _1_()
  local from0 = _let_0_[1]
  local to0 = _let_0_[2]
  local r = {}
  for i = from0, to0, step0 do
    table.insert(r, i)
  end
  return r
end
fu["key-by"] = function(f, tbl)
  local r = {}
  for _, v in pairs(tbl) do
    r[f(v)] = v
  end
  return r
end
fu.capitalize = function(str)
  return string.gsub(str, "^%l", string.upper)
end
fu["seconds->duration"] = function(secs)
  if (secs > 3600) then
    return string.format("%.1f hrs", (secs / 3600))
  elseif (secs > 60) then
    return string.format("%.1f mins", (secs / 60))
  else
    return string.format("%.1f secs", secs)
  end
end
fu["bytes->string"] = function(bytes)
  return fu.join(fu.map(string.char, bytes))
end
return fu
