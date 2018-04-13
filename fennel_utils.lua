local table = table
local pairs = pairs
local next = next
local type = type
local function _0_(x)
  return (type(x)) == (("number"))
end
local number_3f = _0_
local function _1_(x)
  return (type(x)) == (("string"))
end
local string_3f = _1_
local function _2_(x)
  return (type(x)) == (("table"))
end
local table_3f = _2_
local function _3_(x)
  return (type(x)) == (("userdata"))
end
local userdata_3f = _3_
local function _4_(i)
  return (i + 1)
end
local inc = _4_
local function _5_(i)
  return (i - 1)
end
local dec = _5_
local function _6_(it)
  do
    local t = ({})
    for k, v in it do
      t[k] = v
    end
    return t
  end
end
local iter__3etable = _6_
local function _7_(f, tbl)
  do
    local r = ({})
    for k, v in pairs(tbl) do
      r[k] = f(v)
    end
    return r
  end
end
local map = _7_
local function _8_(f, tbl)
  do
    local r = ({})
    for k, v in pairs(tbl) do
      local function _9_()
        if f(v) then
          do
            r[k] = v
            return nil
          end
        end
      end
      _9_()
    end
    return r
  end
end
local filter = _8_
local function _9_(tbl)
  do
    local r = ({})
    for k, v in pairs(tbl) do
      table.insert(r, v)
    end
    return r
  end
end
local vals = _9_
local function _10_(tbl)
  do
    local _, v = next(tbl)
    return v
  end
end
local first = _10_
local function _11_(tbl)
  do
    local k, v1 = next(tbl)
    local _, v2 = next(tbl, k)
    return v2
  end
end
local second = _11_
local function _12_(n, tbl)
  local n = n
  local k = nil
  while (n) > (0) do
    k = next(tbl, k)
    n = dec(n)
  end
  do
    local _, v = next(tbl, k)
    return v
  end
end
local nth = _12_
local function _13_(sep, tbl)
  do
    local function _14_()
      if tbl then
        return ({sep, tbl})
      else
        return ({(""), sep})
      end
    end
    local _15_ = _14_()
    local sep = _15_[1]
    local tbl = _15_[2]
    return table.concat(vals(tbl), (sep or ("")))
  end
end
local join = _13_
local function _14_(from, to, step)
  do
    local function _15_()
      if number_3f(step) then
        return step
      else
        return 1
      end
    end
    local step = _15_()
    local function _16_()
      if number_3f(to) then
        return ({from, to})
      else
        return ({0, from})
      end
    end
    local _17_ = _16_()
    local from = _17_[1]
    local to = _17_[2]
    local r = ({})
    for i = from, to, step do
      table.insert(r, i)
    end
    return r
  end
end
local range = _14_
return ({[("dec")] = dec, [("filter")] = filter, [("first")] = first, [("inc")] = inc, [("iter->table")] = iter__3etable, [("join")] = join, [("map")] = map, [("nth")] = nth, [("number?")] = number_3f, [("range")] = range, [("second")] = second, [("string?")] = string_3f, [("table?")] = table_3f, [("userdata?")] = userdata_3f, [("vals")] = vals})
