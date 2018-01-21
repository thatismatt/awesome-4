------------------------------------------------------------
-- Awesome Prime - An improved remote REPL for Awesome WM
-- @author Matt Lee
-- @copyright Matt Lee
-- Based on awful.remote, by Julien Danjou
------------------------------------------------------------

local dbus     = dbus
                 require("awful.dbus")
local error    = error
local load     = loadstring or load -- v5.1 - loadstring, v5.2 - load
local pairs    = pairs
local select   = select
local string   = string
local table    = table
local tostring = tostring
local type     = type
local pcall    = pcall

-- module("prime")

local prime = {}

prime.default_command_id = "r"

prime.commands = {
   r = {
      name = "raw return",
      handle = tostring
   },
   t = {
      name = "type",
      handle = function (v)
         return tostring(type(v))
      end
   },
   h = {
      name = "help",
      response = function ()
         local help = { "--- Awesome Prime ---", "An improved remote repl for Awesome WM", "Commands:" }
         for id, c in pairs(prime.commands) do
            table.insert(help, "  :" .. id .. " - " .. c.name)
         end
         return table.concat(help, "\n")
      end
   }
}

function prime.add_commands (cmds)
   for id, c in pairs(cmds) do
      -- TODO: test for overwriting builtin commands
      prime.commands[id] = c
   end
end

function parse_request (request)
   if request == "" then
      return
   end
   local command_id, code = string.match(request, "^:([a-z]?) ?(.*)$")
   if command_id then
      if command_id == "" then
         command_id = prime.default_command_id
      end
      code = "return " .. code
   else
      command_id = "r"
      code = request
   end
   return command_id, code
end

function process_request (command, code)
   if command.response then
      return command.response()
   else
      local f, e = load(code)
      if f then
         local results = capture_nils(pcall(f))
         -- TODO: make use of results.ok
         local responses = {}
         for k = 1, results.n do
            local v = results[k]
            table.insert(responses, command.handle(v))
         end
         return table.concat(responses, "\n")
      else
         return tostring(e or "unknown error")
      end
   end
end

function capture_nils (ok, ...)
   -- explicitly capture the length as n, see http://lua-users.org/wiki/StoringNilsInTables
   return { ok = ok, n = select('#', ...), ... }
end

function initialise ()
   dbus.request_name("session", "thatismatt.awesome")
   dbus.connect_signal(
      "thatismatt.awesome.Prime",
      function (data, request)
         if data.member == "Eval" then
            local command_id, code = parse_request(request)
            if not command_id then
               return
            end
            local command = prime.commands[command_id]
            local response = "Unknown command: " .. command_id
            if command then
               response = process_request(command, code)
            end
            -- add newlines that are removed in awesome-prime shell script
            return "s", "\n" .. response .. "\n"
         end
      end
   )
end

if dbus then
   initialise()
else
   error("prime: unable to connect to dbus")
end

return prime
