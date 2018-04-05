local table = table
local pairs = pairs
local next = next
local function _0_(it)
  do
    local t = ({})
    for k, v in it do
      t[k] = v
    end
    return t
  end
end
local iter__3etable = _0_
local function _1_(f, tbl)
  do
    local r = ({})
    for k, v in pairs(tbl) do
      r[k] = f(v)
    end
    return r
  end
end
local map = _1_
local function _2_(f, tbl)
  do
    local r = ({})
    for k, v in pairs(tbl) do
      local function _3_()
        if f(v) then
          do
            r[k] = v
            return nil
          end
        end
      end
      _3_()
    end
    return r
  end
end
local filter = _2_
local function _3_(tbl)
  do
    local r = ({})
    for k, v in pairs(tbl) do
      table.insert(r, v)
    end
    return r
  end
end
local vals = _3_
local function _4_(tbl)
  do
    local _, v = next(tbl)
    return v
  end
end
local first = _4_
local function _5_(sep, tbl)
  do
    local function _6_()
      if tbl then
        return ({sep, tbl})
      else
        return ({(""), sep})
      end
    end
    local _7_ = _6_()
    local sep = _7_[1]
    local tbl = _7_[2]
    return table.concat(vals(tbl), (sep or ("")))
  end
end
local join = _5_
return ({[("filter")] = filter, [("first")] = first, [("iter->table")] = iter__3etable, [("join")] = join, [("map")] = map, [("vals")] = vals})
