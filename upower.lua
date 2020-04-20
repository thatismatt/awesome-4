local dbus = require("dbus_proxy")
local fu = require("fennel_utils")
local device_states = {"charging", "discharging", "empty", "full"}
local function create_device(path)
  return (dbus.Proxy):new({bus = dbus.Bus.SYSTEM, interface = "org.freedesktop.UPower.Device", name = "org.freedesktop.UPower", path = path})
end
local function device__3elabel(device)
  local device_state = device_states[device.State]
  local details = nil
  do
    local _0_0 = device_state
    if (_0_0 == "charging") then
      details = (fu["seconds->duration"](device.TimeToFull) .. " to full")
    elseif (_0_0 == "discharging") then
      details = (fu["seconds->duration"](device.TimeToEmpty) .. " to empty")
    elseif (_0_0 == "full") then
      details = "full"
    elseif (_0_0 == "empty") then
      details = "empty"
    else
    details = nil
    end
  end
  return (device.Percentage .. "% (" .. details .. ")")
end
return {["create-device"] = create_device, ["device->label"] = device__3elabel}
