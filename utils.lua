--------------------------------
-- thatismatt's awesome utils --
--------------------------------

local gears = require("gears")
local io = io
local os = os
local table = table
local pairs = pairs
local string = string
local tostring = tostring
local tonumber = tonumber
local type = type
local timer = timer

local utils = {}

utils.log = function (...)
   local date = os.date("%Y-%m-%d")
   local filename = os.getenv("HOME") .. "/tmp/awesome-" .. date .. ".log"
   local f = io.open(filename, "a")
   f:write(os.date("[%H:%M:%S]") .. " " .. table.concat(utils.map({...}, tostring), " ") .. "\n")
   f:close()
end

utils.iter_to_tbl = function (iter)
   local r = {}
   for i in iter do
      table.insert(r, i)
   end
   return r
end

utils.map = function (tbl, f)
   local r = {}
   for k, v in pairs(tbl) do
      r[k] = f(v)
   end
   return r
end

utils.filter = function (tbl, f)
   local r = {}
   for k, v in pairs(tbl) do
      if f(v) then
         r[k] = v
      end
   end
   return r
end

utils.find = function (tbl, f)
   for k, v in pairs(tbl) do
      if f(v) then
         return v
      end
   end
end

utils.flatmap = function (tbl, f)
   return utils.concat(utils.map(tbl, f))
end

utils.map_kv = function (tbl, f)
   local r = {}
   for k, v in pairs(tbl) do
      local k1, v1 = f(k, v)
      r[k1] = v1
   end
   return r
end

utils.keys = function (tbl)
   local r = {}
   for k, v in pairs(tbl) do
      table.insert(r, k)
   end
   return r
end

utils.vals = function (tbl)
   local r = {}
   for k, v in pairs(tbl) do
      table.insert(r, v)
   end
   return r
end

utils.concat = function (tbls)
   local r = {}
   for k, v in pairs(tbls) do
      r = gears.table.join(r, v)
   end
   return r
end

utils.union = function (...)
   local set = {}
   local ret = {}
   for k, v in pairs(utils.concat({...})) do
      if not set[v] then
         table.insert(ret, v)
         set[v] = true
      end
   end
   return ret
end

utils.range = function (from, to)
   if not to then
      to = from
      from = 1
   end
   local r = {}
   for i = from, to do
      table.insert(r, i)
   end
   return r
end

utils.tail = function (tbl)
   return utils.map(
      utils.range(2, #tbl),
      function (i) return tbl[i] end)
end

utils.sort = function (tbl)
   local r = utils.map(tbl, function (x) return x end)
   table.sort(r)
   return r
end

utils.async = function (f)
   local x = timer({ timeout = 0 })
   x:connect_signal("timeout", function() f(); x:stop() end)
   x:start()
end

utils.intr = function (tbl)
   local format_key = function (k)
      local tabs = 2
      if string.len(tostring(k)) > 7 then
         tabs = 1
      end
      return k .. string.rep("\t", tabs) .. tostring(tbl[k])
   end
   local lines = utils.map(
      utils.keys(tbl),
      format_key)
   return table.concat(lines, "\n")
end

utils.read_all = function (cmd)
   local fd = io.popen(cmd)
   local line = fd:read("*all")
   fd:close()
   return line
end

return utils
